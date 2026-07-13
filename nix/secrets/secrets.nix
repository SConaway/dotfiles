let
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHa5ZkCZmgH2SA1S1BolZMm7172xb0AlOzkG1iYYJ32R";

  ca-qb = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvr1ijV/l3HQjJHwVrR4H2u+kVhWq0i15ZKMzNQRc9L";
  nixpi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+TKkDGH+mGN9pGtr2Itswro73xlp94qSDU80NBi5cO";
  ca-lyfe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuHmsK8p8diqygxzukYydUY3XY/VuuaC203CmrSc1Fe";
  id-attic = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJssKz+xwWfNM+ZUu5VfuLlZQkMFcqLUhrfnffC1qAZP";
  ca-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFW0fbol4QVcMuwvVcFAzKickzXNbAyfet2jjMW3TCXk";
in
{
  "ca-qb/wireguard.age".publicKeys = [ ca-qb user ];
  "nixpi/wifi-psk.age".publicKeys = [ nixpi user ];
  "id-attic/atticd-jwt.age".publicKeys = [ id-attic user ];
  # Decryptable by ca-work (its host key) and mac (the "user" key is
  # steven's personal key, already used as mac's agenix identity).
  "attic-push-token.age".publicKeys = [ ca-work user ];
}
