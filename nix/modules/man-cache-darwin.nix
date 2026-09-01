{ ... }:

{
  # nix-darwin has no `documentation.man.cache.enable` like NixOS, so
  # apropos/man -k never finds anything unless we build the mandb caches
  # ourselves. Linux hosts get this for free via
  # `documentation.man.cache.enable` in modules/linux.nix.
  #
  # Background on how man-db actually finds a cache, since it's not obvious
  # from the config alone: `man -k`/`apropos` walk each directory in the
  # effective MANPATH, and for each one consult a `MANDB_MAP <dir> <cache>`
  # directive to find where its whatis/apropos index lives. Nothing scans
  # the man page directories live -- if a directory has no matching
  # MANDB_MAP entry (or the entry points at a cache that was never built),
  # that directory is silently invisible to `-k` lookups even though `man
  # <page>` still works fine by walking the filesystem directly.
  #
  # `programs.man.man-db.extraConfig` (set below) is how home-manager gets
  # our MANDB_MAP directives in front of man-db at all: it writes them into
  # ~/.manpath, a per-user supplementary config file that man-db reads in
  # addition to its own compiled-in /etc/man_db.conf. That file already ends
  # up containing one MANDB_MAP line generated automatically by
  # `programs.man.generateCaches` for `home.packages`; everything else in
  # this file adds more lines to it for man pages home-manager doesn't
  # already know about.
  #
  # There are two fundamentally different kinds of "man pages home-manager
  # doesn't know about" here, and they need different mechanisms:
  #
  #   1. `environment.systemPackages` -- these ARE nix derivations, just not
  #      ones home-manager's own `generateCaches` sees (that only looks at
  #      `home.packages`). We can build a cache for them the same way nix
  #      builds everything else: a derivation, rebuilt automatically by nix
  #      whenever the package set changes. See `systemManPages`/
  #      `systemManCache` below.
  #
  #   2. Apple's own tools, Homebrew formulae/casks, and anything dropped
  #      into /usr/local -- these are NOT nix derivations at all. Their
  #      content changes via `brew install`/`brew upgrade` or a macOS
  #      update, completely outside of any nix rebuild. A derivation built
  #      by reading `/usr/share/man` at build time would capture whatever
  #      was there on the day it first built and then go stale forever:
  #      nix has no way to know the directory's contents later changed, so
  #      it would never rebuild the cache. These need to be rebuilt outside
  #      of nix's dependency tracking entirely, on every activation. See
  #      `externalManSources` below.
  home-manager.users.steven =
    {
      config,
      pkgs,
      lib,
      osConfig,
      ...
    }:
    let
      # Cache for environment.systemPackages (aerospace, git, ripgrep, ...).
      #
      # `paths = osConfig.environment.systemPackages` is a straightforward
      # nix dependency: buildEnv's output path changes whenever that package
      # list (or any package in it) changes, so `systemManCache` below is
      # automatically rebuilt by nix on the next switch. No activation
      # script or staleness concerns here, unlike externalManSources.
      #
      # Built independently of /run/current-system/sw (rather than reusing
      # it directly) to avoid a dependency cycle with the system closure:
      # the system closure's own build would need to know about this cache,
      # which would need to know about the system closure. Same trick
      # NixOS's own man-db module uses.
      systemManPages = pkgs.buildEnv {
        name = "system-man-paths";
        paths = osConfig.environment.systemPackages;
        pathsToLink = [ "/share/man" ];
        extraOutputsToInstall = [ "man" ];
        ignoreCollisions = true;
      };

      # `-C man.conf` points mandb at a throwaway config containing only the
      # one MANDB_MAP line it needs to know where to write the cache;
      # `--create` builds it from scratch since there's nothing to update
      # incrementally on a fresh derivation. This exact recipe is what
      # `externalManSources` below tries to reuse for /usr/share/man and
      # friends -- and where it turns out this only works for nix store
      # paths like this one. See the comment down there for why.
      systemManCache =
        pkgs.runCommandLocal "system-man-cache"
          {
            nativeBuildInputs = [ config.programs.man.package ];
          }
          ''
            echo "MANDB_MAP ${systemManPages}/share/man $out" > man.conf
            mandb -C man.conf --no-straycats --create ${systemManPages}/share/man
          '';

      # Where the mandb caches for the external (non-nix) sources below
      # live. Deliberately a plain mutable directory in $HOME, not a nix
      # store path -- these caches get overwritten in place by the
      # activation script on every switch, which wouldn't be possible (or
      # meaningful) for a content-addressed store path.
      externalManCacheDir = "${config.home.homeDirectory}/.cache/man-external";

      # Non-nix man page sources to cache: Apple's own tools (launchctl,
      # etc.), Homebrew formulae/casks, and anything manually dropped into
      # /usr/local. Add more entries here if another such directory turns
      # up (e.g. a MacPorts prefix) -- both the activation script and the
      # extraConfig below are generated from this one attrset.
      externalManSources = {
        apple = "/usr/share/man";
        homebrew = "/opt/homebrew/share/man";
        local = "/usr/local/share/man";
      };

      # Xcode/CommandLineTools man pages (clang, xcodebuild, ...) -- these
      # need a third mechanism, distinct from both nix derivations above and
      # externalManSources above. externalManSources still works for a
      # *directory whose path is fixed* even though its *contents* are
      # mutable (mandb rebuilds the cache every activation, but always
      # against the same literal path, so a plain MANDB_MAP for that literal
      # path is knowable at eval time). Here the path itself is what's
      # mutable: it's wherever `xcode-select -p` currently points --
      # /Library/Developer/CommandLineTools, /Applications/Xcode.app/...,
      # /Applications/Xcode-beta.app/..., and it can change any time the
      # user runs `xcode-select -s`, entirely outside of nix or even of a
      # `darwin-rebuild switch`.
      #
      # A literal path that can't be known at eval time can't appear on the
      # left of a MANDB_MAP/MANDATORY_MANPATH directive, since those files
      # are only regenerated on switch. So instead of pointing man-db at the
      # real (unknowable) path, we point it at a fixed alias symlink under
      # externalManCacheDir -- itself a literal, eval-time-known path -- and
      # have the activation script re-target that symlink at whatever
      # `xcode-select -p` resolves to, every activation. `MANDATORY_MANPATH`
      # (below, in extraConfig) is what actually pulls the alias into
      # man-db's search path at all: unlike externalManSources' real
      # sources, nothing about $PATH would ever lead man-db to a directory
      # under ~/.cache on its own.
      #
      # Values are relative to `xcode-select -p`; add another entry here if
      # a tool's man page turns up somewhere else under the developer dir
      # (e.g. a platform SDK).
      xcodeManSources = {
        xcode-usr = "usr/share/man";
        xcode-toolchain = "Toolchains/XcodeDefault.xctoolchain/usr/share/man";
      };
    in
    {
      # Cache for home.packages (nvim, zsh, atuin, ...). This is the one
      # cache in this whole file we don't have to build ourselves --
      # home-manager's own man module already knows how, we just have to
      # turn it on.
      programs.man.generateCaches = true;

      # None of the above matters for a bare `man`/`apropos`/`whatis` typed
      # at the prompt unless that word actually resolves to *this* man-db.
      # On macOS, /etc/zprofile's path_helper puts /usr/bin ahead of
      # anything nix adds later, so those commands otherwise hit Apple's
      # own man/apropos -- a completely separate implementation (BSD-style
      # script, not GNU man-db) that has no notion of ~/.manpath or
      # MANDB_MAP at all. It wouldn't ignore the caches built by this file,
      # it just never looks at the config that points to them.
      #
      # Fixed generally (not just for man/apropos/whatis) by pulling the
      # nix profile bin dirs back to the front of PATH. `lib.mkAfter` pins
      # this to the end of the generated .zshrc so it runs after
      # path_helper and any other PATH-setting has already happened;
      # `typeset -U path` keeps the array deduplicated so this doesn't
      # leave duplicate entries behind.
      programs.zsh.initContent = lib.mkAfter ''
        typeset -U path
        path=(
          ${config.home.profileDirectory}/bin
          /run/current-system/sw/bin
          $path
        )
      '';

      # Wires the two nix-managed caches (home.packages via
      # generateCaches above, environment.systemPackages via
      # systemManCache) and the three external caches (built by the
      # activation script below) into ~/.manpath, keyed by the real,
      # literal source directory in every case. For the external sources
      # this is the *other* half of the alias trick described in the
      # activation script: mandb refused to build a cache when told to
      # write it for these literal paths, but reading a pre-built cache
      # through a MANDB_MAP keyed on the literal path works fine -- it's
      # only cache *creation* against these paths that man-db special-cases.
      programs.man.man-db.extraConfig =
        ''
          MANDB_MAP /run/current-system/sw/share/man ${systemManCache}
        ''
        + lib.concatStrings (
          lib.mapAttrsToList (name: src: "MANDB_MAP ${src} ${externalManCacheDir}/${name}\n") externalManSources
        )
        + lib.concatStrings (
          lib.mapAttrsToList (name: _: ''
            MANDATORY_MANPATH ${externalManCacheDir}/${name}-src
            MANDB_MAP ${externalManCacheDir}/${name}-src ${externalManCacheDir}/${name}
          '') xcodeManSources
        );

      # Rebuilds the mandb caches for externalManSources on every home-manager
      # activation (i.e. every `darwin-rebuild switch`), since -- unlike the
      # two nix-managed caches above -- nothing about their inputs is
      # visible to nix's dependency tracking. `entryAfter [ "writeBoundary" ]`
      # just means "run after home-manager has finished writing out files
      # like ~/.manpath", so the MANDB_MAP destinations referenced above
      # already exist as paths by the time we populate them.
      home.activation.manCacheExternal = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        ''
          $DRY_RUN_CMD mkdir -p "${externalManCacheDir}"

          # Shared by the externalManSources loop and the dynamic Xcode
          # block below: builds/refreshes the alias symlink + mandb cache
          # for one name/real-directory pair.
          #
          # Building this straightforwardly -- `mandb -C conf --create
          # "$src"` with conf mapping "$src" directly to our cache dir, the
          # same recipe systemManCache above uses -- silently does NOT work
          # for /usr/share/man or /usr/local/share/man (though it does for
          # /opt/homebrew/share/man). Verified by hand: man-db still tries
          # to write its cache under /var/cache/man, which doesn't exist on
          # macOS and isn't created by anything, and fails without ever
          # consulting our MANDB_MAP override. This is man-db upstream's own
          # doing, not a nixpkgs packaging bug: it hardcodes a handful of
          # canonical FHS paths (visible as MANDB_MAP lines already present
          # in its own default man_db.conf) to a single systemwide cache
          # location, apparently so any process running mandb against one
          # of them lands in the same place regardless of who's asking --
          # and it enforces this by exact string match on the source path,
          # ignoring a -C override for cache *creation* against that
          # literal path specifically.
          #
          # Building against a symlink alias instead sidesteps the match
          # (the alias's path string doesn't equal the hardcoded one),
          # while the resulting cache is byte-for-byte what a "real" build
          # against the source would have produced, since mandb only cares
          # about the alias's contents, not its name. Lookups through
          # MANDB_MAP for the real source (externalManSources, via
          # extraConfig above) or through the alias itself
          # (xcodeManSources, via MANDATORY_MANPATH in extraConfig) then
          # work fine either way, because those are plain config-driven
          # reads, not cache-creation calls.
          build_external_man_cache() {
            local name="$1" src="$2"
            local alias="${externalManCacheDir}/$name-src"
            local conf="${externalManCacheDir}/$name.conf"
            $DRY_RUN_CMD ln -sfn "$src" "$alias"
            printf 'MANDB_MAP %s %s\n' "$alias" "${externalManCacheDir}/$name" > "$conf"
            $DRY_RUN_CMD ${config.programs.man.package}/bin/mandb -C "$conf" --no-straycats --create "$alias" >/dev/null
          }
        ''
        + lib.concatStrings (
          lib.mapAttrsToList (name: src: ''
            if [ -d "${src}" ]; then
              build_external_man_cache "${name}" "${src}"
            fi
          '') externalManSources
        )
        + ''

          # Xcode/CommandLineTools man pages -- see the xcodeManSources
          # comment above for why this needs its own block instead of just
          # being another externalManSources entry. Re-resolved every
          # activation since `xcode-select -s` can repoint this at any
          # time, independent of any nix rebuild.
          xcodeDev=$(/usr/bin/xcode-select -p 2>/dev/null || true)
        ''
        + lib.concatStrings (
          lib.mapAttrsToList (name: relPath: ''
            if [ -n "$xcodeDev" ] && [ -d "$xcodeDev/${relPath}" ]; then
              build_external_man_cache "${name}" "$xcodeDev/${relPath}"
            else
              # Xcode uninstalled, switched, or this particular man dir
              # doesn't exist under the active developer dir -- drop any
              # stale alias so MANDATORY_MANPATH (extraConfig above) just
              # skips it instead of pointing man-db at a dead symlink.
              $DRY_RUN_CMD rm -f "${externalManCacheDir}/${name}-src"
            fi
          '') xcodeManSources
        )
      );
    };
}
