{
  disko.devices = {
    disk.main = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          BIOS = {
            size = "1M";
            type = "EF02";
            priority = 1;
          };
          swap = {
            size = "10G";
            priority = 2;
            content = {
              type = "swap";
            };
          };
          root = {
            size = "100%";
            priority = 3;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
