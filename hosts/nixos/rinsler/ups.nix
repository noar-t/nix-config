{ config, pkgs, ... }:

{
  power.ups = {
    enable = true;
    mode = "standalone";

    ups."apc" = {
      driver = "usbhid-ups";
      # USB HID device - auto-detected by driver
      port = "auto";
      description = "APC Back-UPS RS 1000MS";
    };

    upsmon = {
      monitor."apc" = {
        user = "upsmon";
        powerValue = 1;
        type = "primary";
        system = "apc@localhost";
      };

      settings = {
        # Minimum power supplies to keep system running
        MINSUPPLIES = 1;

        # Enable automatic shutdown on low battery
        SHUTDOWNCMD = "${pkgs.systemd}/bin/systemctl poweroff";

        # Monitor settings for automatic shutdown
        HOSTSYNC = 15;
        DEADTIME = 15;
        POLLFREQ = 5;
        POLLFREQALERT = 2;

        # Notification settings
        NOTIFYCMD = "${pkgs.nut}/bin/upssched";
        NOTIFYFLAG = [
          [
            "ONLINE"
            "SYSLOG"
          ]
          [
            "ONBATT"
            "SYSLOG+WALL+EXEC"
          ]
          [
            "LOWBATT"
            "SYSLOG+WALL+EXEC"
          ]
          [
            "REPLBATT"
            "SYSLOG+WALL"
          ]
          [
            "SHUTDOWN"
            "SYSLOG+WALL+EXEC"
          ]
        ];
      };
    };

    users = {
      upsmon = {
        passwordFile = "/var/lib/nut/upsmon.passwd";
        upsmon = "primary";
      };
    };
  };

  # Create password file in a systemd-compatible way
  systemd.tmpfiles.rules = [
    "d /var/lib/nut 0750 root nut -"
    "f /var/lib/nut/upsmon.passwd 0600 root nut -"
  ];

  # Use systemd service to generate password before UPS services start
  systemd.services.nut-password = {
    description = "Generate NUT password";
    wantedBy = [ "multi-user.target" ];
    before = [
      "upsd.service"
      "upsmon.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "generate-nut-password" ''
        if [ ! -s /var/lib/nut/upsmon.passwd ]; then
          ${pkgs.openssl}/bin/openssl rand -base64 32 > /var/lib/nut/upsmon.passwd
          chmod 600 /var/lib/nut/upsmon.passwd
          chown root:nut /var/lib/nut/upsmon.passwd
        fi
      '';
    };
  };
}
