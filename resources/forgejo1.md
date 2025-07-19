[Forgejo](https://forgejo.org/) is a lightweight [software forge](https://en.wikipedia.org/wiki/Software_forge "wikipedia:Software forge"), with a highlight on being completely free software. It's a fork of [Gitea](https://wiki.nixos.org/w/index.php?title=Gitea&action=edit&redlink=1 "Gitea (page does not exist)").

This article extends the documentation in the [NixOS manual](https://nixos.org/manual/nixos/stable/#module-forgejo).

## Usage

NixOs provides a module for easily setting-up a Forgejo server, here is an example of typical usage with some optional features:

-   Use Nginx to enable easy https configuration
-   You can choose what database you want to use (postgres in this example)
-   Support for [git-lfs](https://git-lfs.com/)
-   Disabling registrations for personal servers
-   Support for Actions, similar to Github Actions
-   Support for sending email notifications
-   No exposed secrets in the nix store, see [Comparison of secret managing schemes](https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes "Comparison of secret managing schemes") and choose one

```
{ lib, pkgs, config, ... }:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in
{
  services.nginx = {
    virtualHosts.${cfg.settings.server.DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        client_max_body_size 512M;
      '';
      locations."/".proxyPass = "http://localhost:${toString srv.HTTP_PORT}";
    };
  };

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    # Enable support for Git Large File Storage
    lfs.enable = true;
    settings = {
      server = {
        DOMAIN = "git.example.com";
        # You need to specify this to remove the port from URLs in the web UI.
        ROOT_URL = "https://${srv.DOMAIN}/"; 
        HTTP_PORT = 3000;
      };
      # You can temporarily allow registration to create an admin user.
      service.DISABLE_REGISTRATION = true; 
      # Add support for actions, based on act: https://github.com/nektos/act
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
      # Sending emails is completely optional
      # You can send a test email from the web UI at:
      # Profile Picture > Site Administration > Configuration >  Mailer Configuration 
      mailer = {
        ENABLED = true;
        SMTP_ADDR = "mail.example.com";
        FROM = "noreply@${srv.DOMAIN}";
        USER = "noreply@${srv.DOMAIN}";
      };
    };
    mailerPasswordFile = config.age.secrets.forgejo-mailer-password.path;
  };

  age.secrets.forgejo-mailer-password = {
    file = ../secrets/forgejo-mailer-password.age;
    mode = "400";
    owner = "forgejo";
  };
}

```

## Runner

According to the [documentation](https://forgejo.org/docs/latest/admin/actions/#forgejo-runner) the `Forgejo runner` is:

> A daemon that fetches workflows to run from a Forgejo instance, executes them, sends back with the logs and ultimately reports its success or failure.

In order to use Actions, you will need to setup at least one Runner. You can use your server, another machine or both as runners.

  
To register a runners you will need to generate a token. [https://forgejo.org/docs/latest/user/actions/#forgejo-runner](https://forgejo.org/docs/latest/user/actions/#forgejo-runner)

You can create a server-wide Runner by going to _Profile Picture > Site Administration > Actions > Runners > Create new Runner._

Store your token in your [secrets management system](https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes "Comparison of secret managing schemes") of choice, then add the following to the configuration of the machine to be used as a runner:

```
{ pkgs, config, ... }: {
  services.gitea-actions-runner = {
    package = pkgs.forgejo-actions-runner;
    instances.default = {
      enable = true;
      name = "monolith";
      url = "https://git.example.com";
      # Obtaining the path to the runner token file may differ
      # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
      tokenFile = config.age.secrets.forgejo-runner-token.path;
      labels = [
        "ubuntu-latest:docker://node:16-bullseye"
        "ubuntu-22.04:docker://node:16-bullseye"
        "ubuntu-20.04:docker://node:16-bullseye"
        "ubuntu-18.04:docker://node:16-buster"     
        ## optionally provide native execution on the host:
        # "native:host"
      ];
    };
  };
}

```

## Ensure users

Using the following snippet, you can ensure users:

```
sops.secrets.forgejo-admin-password.owner = "forgejo";
systemd.services.forgejo.preStart = let 
  adminCmd = "${lib.getExe cfg.package} admin user";
  pwd = config.sops.secrets.forgejo-admin-password;
  user = "joe"; # Note, Forgejo doesn't allow creation of an account named "admin"
in ''
  ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
  ## uncomment this line to change an admin user which was already created
  # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
'';

```

You may remove the `--admin` flag to create only a regular user. The `|| true` is necessary, so the snippet does not fail if the user already exists.

Naturally, instead of sops, you may use any file or secret manager, as explained above.