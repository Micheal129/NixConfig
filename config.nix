# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./boot.nix
      #./harden.nix
    ];

  #Ios support
  
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
 
  #for standalone excuables
    programs.nix-ld.enable = true;
     programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    zsh
  ];

  services.udev.packages = [
    pkgs.android-udev-rules
    pkgs.hackrf
  ];


  #dns
#  networking = {
 #     nameservers = [ "127.0.0.1" "::1" ];
 #     # If using dhcpcd:
 #     dhcpcd.extraConfig = "nohook resolv.conf";
 #     # If using NetworkManager:
 #     networkmanager.dns = "none";
 #   };
#  services.dnscrypt-proxy2 = {
#      enable = true;
#      settings = {
#        ipv6_servers = true;
#        require_dnssec = true;
#  
#        sources.public-resolvers = {
#          urls = [
#            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
#            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
#          ];
#          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
#          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
#        };
#  
#        # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
#         server_names = [ "ahadns-doh-la" ];
#      };
#    };
#  
#    systemd.services.dnscrypt-proxy2.serviceConfig = {
#      StateDirectory = "dnscrypt-proxy";
#    };
  
  # Gpu
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  
  services.joycond.enable = true;
  
 

   boot.kernelModules = [
    "amdgpu"
    "pci_stub"
    "vfio_virqfd"
    "vfio_pci"
    "vfio_iommu_type1"
    "vfio"
  ];

    boot.blacklistedKernelModules = [
    # Obscure network protocols
    "ax25"
    "netrom"
    "rose"

    # Old or rare or insufficiently audited filesystems
    "adfs"
    "affs"
    "bfs"
    "befs"
    "cramfs"
    "efs"
    "erofs"
    "exofs"
    "freevxfs"
    "f2fs"
    "hfs"
    "hpfs"
    "jfs"
    "minix"
    "nilfs2"
    "ntfs"
    "omfs"
    "qnx4"
    "qnx6"
    "sysv"
    "ufs"
  ];

  boot.kernelParams = [
    "slub_debug=FZPU"
    "init_memory=0"
    "page_alloc.shuffle=1"
    "mce=0"
    "randomize_kstack_offset=on"
  ];
  programs.rog-control-center.enable = true;

    hardware = {
    sensor.iio.enable = true;
    enableRedistributableFirmware = true;
  };
  
    # AMD settings
  

    services.thermald.enable = true;
  #Hip
  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.udev.extraRules = ''
  ATTR{idVendor}=="1d50", ATTR{idProduct}=="604b", SYMLINK+="hackrf-jawbreaker-%k", TAG+="uaccess"
  ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", SYMLINK+="hackrf-one-%k", TAG+="uaccess"
  ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", SYMLINK+="rad1o-%k", TAG+="uaccess"
  ATTR{idVendor}=="1fc9", ATTR{idProduct}=="000c", SYMLINK+="nxp-dfu-%k", TAG+="uaccess"
   SUBSYSTEMS=="usb", ATTRS{manufacturer}=="NVIDIA Corp.", ATTRS{product}=="APX", GROUP="nintendo_switch"'
  '';

  boot.initrd.luks.devices."luks-62eb34e1-9da2-4e4d-9352-1444fc7c8421".device = "/dev/disk/by-uuid/62eb34e1-9da2-4e4d-9352-1444fc7c8421";
  networking.hostName = "linux"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;


  #HARDINNING
  #Memory alocator
  #environment.memoryAllocator.provider = "scudo";
  #environment.variables.SCUDO_OPTIONS = "ZeroContents=1";
  boot.kernel.sysctl."kernel.yama.ptrace_scope" =  2;
  boot.kernel.sysctl."net.core.bpf_jit_enable" =  false;
  boot.kernel.sysctl."kernel.ftrace_enabled" =  false;
  boot.kernel.sysctl."kernel.randomize_va_space" =  2;
  boot.kernel.sysctl."fs.suid_dumpable" = 0;
  boot.kernel.sysctl."kernel.dmesg_restrict" =  1;
  boot.consoleLogLevel =  3;
  boot.kernel.sysctl."vm.unprivileged_userfaultfd" = 0;
  security.protectKernelImage = true;
  boot.kernel.sysctl."kernel.sysrq" = 0;
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 0;
  security.virtualisation.flushL1DataCache = "always";
  
#services.fwupd.enable = true;

  
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enableHidpi = true;
  
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Powersave
  powerManagement.enable = true;


  # Enable CUPS to print documents.
  services.printing.enable = true;

 

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  #virtualisation.podman = {
  #  enable = true;
  #  dockerCompat = true;
  #};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ephraim = {
    isNormalUser = true;
    description = "Ephraim Lipp";
    extraGroups = [ "networkmanager" "wheel" "dialout" "docker" "plugdev" "libvirtd" ];
    packages = with pkgs; [
      kate
      thunderbird
      librewolf
      alacritty
      android-tools
      gparted
      openssh
      qalculate-gtk
      python3
      pipx
      android-tools
      qbittorrent
      superTux
      superTuxKart
      tutanota-desktop
      bottles-unwrapped
      ryujinx
      #cemu
      dolphin-emu
      aria2
      mission-center
      haskellPackages.linux-mount
      unrar-wrapper 
      docker
      docker-compose
      jan
      bisq-desktop
      msr
      msr-tools
      kdePackages.isoimagewriter
      vlc
      prismlauncher
      rpi-imager
      gabutdm
     ];
  };

  # Remove sound.enable or set it to false if you had it set previously, as sound.enable is only meant for ALSA-based configurations
  
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  #WD BLUE
   environment.etc.crypttab.text = ''
    cryptstorage UUID=e9f58bde-ab24-488a-b700-a50c18999f0b /root/mykeyfile.key
  '';
  hardware.xone.enable = true;
  hardware.xpadneo.enable = true;
  hardware.hackrf.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    micro
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    xmrig-mo
    p2pool
    nano
    sddm-sugar-dark
    android-udev-rules
    android-tools
    monero-cli    
    git
    gnuradio
    (gnuradio.override {
          extraPackages = with gnuradioPackages; [
            osmosdr
            hackrf
            soapyhackrf
          ];
          extraPythonPackages = with gnuradio.python.pkgs; [
            numpy
          ];
        })
    
    docker
    kdePackages.sddm-kcm
    podman
    radeontop
    powertop
    config.boot.kernelPackages.turbostat
    config.boot.kernelPackages.cpupower
    #pkgs.cudatoolkit # TODO: Maybe add this again when there is more internet
    ryzenadj
    asusctl
    # pkgs.cudaPackages.cuda-samples
    pciutils
    virtualenv
    python312Packages.pip
    zsh
    oh-my-zsh
    hackrf
    hackgen-nf-font
    kdePackages.merkuro
    acpi
    joycond-cemuhook
    lutris
    cartridges
    fusee-interfacee-tk
    motrix    
    dxvk
    dxvk_2
    vkd3d
    flatpak
    zulu
    pv
    gnutar
    wiiuse
    wiimms-iso-tools
    p7zip
    linux-wifi-hotspot
    bc
    dialog
    kdePackages.kdeconnect-kde
    niv
    qpwgraph
    aw-server-rust
    aw-qt
    awatcher
    sdrangel
    #ungoogled-chromium
    sdr-j-fm
      catppuccin-sddm
    sdrpp
    gqrx
    distrobox
    rustup
    ffmpeg
    gcc
    ifuse
    usbmuxd
    libimobiledevice
    clang
    peazip
    gnuradio
    sddm-astronaut
    hackrf
    sbctl
    (lutris.override {
           extraPkgs = pkgs: [
             # List package dependencies here
             mesa
             wineWowPackages.waylandFull
              ];
        })
    temurin-jre-bin
    temurin-jre-bin-8
    temurin-jre-bin-17
    (prismlauncher.override { jdks = [ temurin-jre-bin
    temurin-jre-bin-8
    temurin-jre-bin-17
    temurin-jre-bin ]; })
    asusctl    
    #fwupd
    # support both 32- and 64-bit applications
    #wineWowPackages.stable

    # support 32-bit only
    #wine

    # support 64-bit only
    #(wine.override { wineBuild = "wine64";})

    # support 64-bit only
    #wine64

    # wine-staging (version with experimental features)
    #wineWowPackages.staging

    # winetricks (all versions)
    winetricks

    # native wayland support (unstable)
    wineWowPackages.waylandFull
        ];
            
      hardware.bluetooth.enable = true; # enables support for Bluetooth
      hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;


    services.supergfxd = {
    enable = true;
    settings = {
      # mode = "Integrated";
      vfio_enable = true;
      vfio_save = false;
      always_reboot = false;
      no_logind = false;
      logout_timeout_s = 20;
      hotplug_type = "Asus";
      };
    };
    programs.corectrl.enable = true;
    systemd.services.supergfxd.path = [ pkgs.kmod pkgs.pciutils ];
    hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
      rocmPackages.clr.icd
      mesa
      vulkan-loader
      vulkan-validation-layers
      vulkan-extension-layer
      ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
    services.asusd = {
    enable = true;
    enableUserService = true;
    # fanCurvesConfig = builtins.readFile ../config/fan_curves.ron;
  };
    services.acpid.enable = true;
  services.udev.extraHwdb = ''
    evdev:input:b0003v0B05p19B6*
      KEYBOARD_KEY_ff31007c=f20 # x11 mic-mute
  '';
  
  #ZSH
  users.defaultUserShell=pkgs.zsh; 
  programs = {
   zsh = {
      enable = true;
      autosuggestions.enable = true;
      zsh-autoenv.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
         enable = true;
         theme = "agnoster";
         plugins = [
           "git"
           "npm"
           "history"
           "node"
           "rust"
           "deno"
         ];
      };
   };
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comm


}
