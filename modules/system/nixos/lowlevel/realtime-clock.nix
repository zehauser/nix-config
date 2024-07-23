{ config, lib, ... }:
{
  options.modules.realtime-clock.enable = lib.mkEnableOption "realtime-clock";

  config = lib.mkIf config.modules.realtime-clock.enable {
    boot.kernelModules = [ "rtc-ds1307" ];
    boot.initrd.kernelModules = [ "rtc-ds1307" ];

    # Looks like either fragment@0 or fragment@2 is not needed, but we'll have to wait to find out which it is until I
    # feel like debugging device tree nonsense again.
    hardware.deviceTree.overlays = [
      {
        name = "r2c-i2c";
        filter = "bcm2711-rpi-4*.dtb";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "brcm,bcm2711";

            fragment@0 {
              target-path = "/soc/i2c0mux/i2c@1";

              __overlay__ {
                #address-cells = <1>;
                #size-cells = <0>;

                status = "okay";

                ds3231@68 {
                  compatible = "maxim,ds3231";
                  reg = <0x68>;
                };
              };
            };

            fragment@1 {
              target-path = "/soc/i2c0mux";

              __overlay__ {
                status = "okay";
              };
            };

            fragment@2 {
              target = <&i2c1>;
              
              __overlay__ {
                #address-cells = <1>;
                #size-cells = <0>;

                status = "okay";

                ds3231@68 {
                  compatible = "maxim,ds3231";
                  reg = <0x68>;
                };
              };
            };
          };'';
      }
    ];
  };
}
