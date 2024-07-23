{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "usbhid"
  ];

  hardware.enableRedistributableFirmware = true;

  powerManagement.cpuFreqGovernor = "ondemand";
}
