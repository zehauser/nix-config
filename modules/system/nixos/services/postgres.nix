{ config, lib, ... }:
lib.mkIf config.services.postgresql.enable { services.postgresql.dataDir = "/persistent/databases/postgres"; }
