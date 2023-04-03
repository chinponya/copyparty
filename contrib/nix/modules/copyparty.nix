{ config, pkgs, lib, ... }:

with lib;

let
  name = "copyparty";
  cfg = config.services.copyparty;
  configFile = pkgs.writeText "copyparty.conf" cfg.config;
  bin = "${pkg}/bin/${name}";
in {
  options.services.copyparty = {
    enable = mkEnableOption "web-based file manager";

    package = mkOption {
      type = types.package;
      default = pkgs.copyparty;
      defaultText = "pkgs.copyparty";
      description = ''
        Package of the application to run, exposed for overriding purposes.
      '';
    };

    fileRoot = mkOption {
      default = "/var/lib/${name}";
      type = types.str;
      description = "Path permitted for read/write.";
    };

    openFilesLimit = mkOption {
      default = 4096;
      type = types.either types.int types.str;
      description = "Number of files to allow copyparty to open.";
    };

    config = mkOption {
      type = types.lines;
      description =
        "Configuration file. See https://github.com/9001/copyparty#server-config for reference";
      default = ''
        -i 127.0.0.1
        --no-reload

        # create a volume:
        # share "${cfg.fileRoot}"
        # as "/" (the webroot) for the following users:
        # "r" grants read-access for anyone
        ${cfg.fileRoot}
        /
        r
      '';
      example = ''
        -i 0.0.0.0
        --no-reload

        # create users:
        # u username:password
        u ed:123

        # create a volume:
        # share "." (the current directory)
        # as "/" (the webroot) for the following users:
        # "r" grants read-access for anyone
        # "rw ed" grants read-write to ed
        .
        /
        r
        rw ed
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.copyparty = {
      description = "http file sharing hub";
      wantedBy = [ "multi-user.target" ];

      environment = { PYTHONUNBUFFERED = "true"; };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${bin} -c ${configFile}";

        # Hardening options
        User = "copyparty";
        Group = "copyparty";
        RuntimeDirectory = "copyparty";
        RuntimeDirectoryMode = "0700";
        StateDirectory = "copyparty";
        StateDirectoryMode = "0755";
        ReadWritePaths = cfg.fileRoot;
        WorkingDirectory = "/var/lib/copyparty";

        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        PrivateMounts = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictNamespaces = true;
        RemoveIPC = true;
        UMask = "0077";
        LimitNOFILE = cfg.openFilesLimit;
        NoNewPrivileges = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictAddressFamilies = "AF_INET AF_INET6";
      };
    };

    users.groups.copyparty = { };
    users.users.copyparty = {
      description = "Service user for copyparty";
      group = "copyparty";
      isSystemUser = true;
    };

    environment.systemPackages = [ cfg.package ];
  };
}
