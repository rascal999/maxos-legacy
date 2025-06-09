From NixOS Wiki

Jump to: [navigation](https://nixos.wiki/wiki/Docker#mw-navigation), [search](https://nixos.wiki/wiki/Docker#p-search)

[Docker](https://docker.com/) is a utility to pack, ship and run any application as a lightweight container.

## Docker on NixOS

## Installation

To install docker, add the following to your your NixOS configuration:

```
virtualisation.docker.enable = true;

```

[More options](https://search.nixos.org/options?from=0&size=50&sort=alpha_asc&query=virtualisation.docker) are available.

Adding users to the `docker` group will provide them access to the socket after a restart:

```
users.users.<myuser>.extraGroups = [ "docker" ];

```

If you prefer, you could achieve the same with this:

```
users.extraGroups.docker.members = [ "username-with-access-to-socket" ];

```

If you're still unable to get access to the socket, you might have to re-login or reboot.

**Warning:** Beware that the docker group membership is effectively [equivalent to being root](https://github.com/moby/moby/issues/9976)!  
Consider using rootless mode below.

Note: If you use the [btrfs](https://nixos.wiki/wiki/Btrfs "Btrfs") filesystem, you might need to set the storageDriver option:

```
virtualisation.docker.storageDriver = "btrfs";

```

### Rootless docker

To use docker in [rootless mode](https://docs.docker.com/engine/security/rootless/), you can activate the `rootless` option:

```
virtualisation.docker.rootless = {
  enable = true;
  setSocketVariable = true;
};

```

The `setSocketVariable` option sets the `DOCKER_HOST` variable to the rootless Docker instance for normal users by default.

Docker can now be rootlessly enabled with:

```
$ systemctl --user enable --now docker

```

It's status can be checked with:

```
$ systemctl --user status docker

```

### Changing Docker Daemon's Data Root

By default, the Docker daemon will store images, containers, and build context on the root filesystem.

If you want to change the location that Docker stores its data, you can configure a new `data-root` for the daemon by setting the `data-root` property of the [`virtualisation.docker.daemon.settings`](https://search.nixos.org/options?show=virtualisation.docker.daemon.settings&from=0&size=50&sort=alpha_asc&type=packages&query=virtualisation.docker).

```
virtualisation.docker.daemon.settings = {
  data-root = "/some-place/to-store-the-docker-data";
};

```

### Changing Docker Daemon's Other settings example

The docker daemon settings are pretty extensive, see also: [https://github.com/NixOS/nixpkgs/issues/68349](https://github.com/NixOS/nixpkgs/issues/68349) For example, it is extremely likely that you want to turn off the userland-proxy, which is designed for Windoze.

```
virtualisation.docker.daemon.settings = {
    userland-proxy = false;
    experimental = true;
    metrics-addr = "0.0.0.0:9323";
    ipv6 = true;
    fixed-cidr-v6 = "fd00::/80";
};

```

## Docker Containers as systemd Services

To make sure some docker containers are running as systemd services, you can use 'oci-containers':

```
virtualisation.oci-containers = {
  backend = "docker";
  containers = {
    foo = {
      # ...
    };
  };
};

```

See [https://mynixos.com/options/virtualisation.oci-containers.containers.%3Cname%3E](https://mynixos.com/options/virtualisation.oci-containers.containers.%3Cname%3E) for further options

## Running the docker daemon from nix-the-package-manager - not NixOS

This is not supported. You're better off installing the docker daemon ["the normal non-nix way"](https://docs.docker.com/engine/install/).

See the discourse discussion: [How to run docker daemon from nix (not NixOS)](https://discourse.nixos.org/t/how-to-run-docker-daemon-from-nix-not-nixos/43413) for more.

## Creating images

## Building a docker image with nixpkgs

There is an entry for [dockerTools](https://nixos.org/nixpkgs/manual/#sec-pkgs-dockerTools) in the nixpkgs manual for reference. In the linked page they give the following example config:

```
buildImage {
  name = "redis";
  tag = "latest";

  fromImage = someBaseImage;
  fromImageName = null;
  fromImageTag = "latest";

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [ pkgs.redis ];
    pathsToLink = [ "/bin" ];
  };

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    mkdir -p /data
  '';

  config = {
    Cmd = [ "/bin/redis-server" ];
    WorkingDir = "/data";
    Volumes = { "/data" = { }; };
  };

  diskSize = 1024;
  buildVMMemorySize = 512;
}

```

More examples can be found in the [nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/docker/examples.nix) repo.

Also check out the excellent article by [lethalman](https://lucabrunox.github.io/2016/04/cheap-docker-images-with-nix_15.html) about building minimal docker images with nix.

### Reproducible image dates

The manual advises against using `created = "now"`, as that prevents images from being reproducible.

An alternative, if using [flakes](https://nixos.wiki/wiki/Flakes "Flakes"), is to do `created = builtins.substring 0 8 self.lastModifiedDate`, which uses the commit date, and is therefore reproducible.

### How to calculate the `sha256` of a pulled image

The `sha256` argument of the `dockerTools.pullImage` function is the checksum of the archive generated by Skopeo. Since the archive contains the name and the tag of the image, Skopeo arguments used to fetch the image have to be identical to those used by the `dockerTools.pullImage` function.

For instance, the sha of the following image

```
pkgs.dockerTools.pullImage{
  imageName = "lnl7/nix";
  finalImageTag = "2.0";
  imageDigest = "sha256:632268d5fd9ca87169c65353db99be8b4e2eb41833b626e09688f484222e860f";
  sha256 = "1x00ks05cz89k3wc460i03iyyjr7wlr28krk7znavfy2qx5a0hfd";
};

```

can be manually generated with the following shell commands

```
skopeo copy docker://lnl7/nix@sha256:632268d5fd9ca87169c65353db99be8b4e2eb41833b626e09688f484222e860f docker-archive:///tmp/image.tgz:lnl7/nix:2.0

```

```
nix-hash --base32 --flat --type sha256 /tmp/image.tgz

```

```
1x00ks05cz89k3wc460i03iyyjr7wlr28krk7znavfy2qx5a0hfd

```

### Directly Using Nix in Image Layers

Instead of copying Nix packages into Docker image layers, Docker can be configured to directly utilize the `nix-store` by integrating with [nix-snapshotter](https://github.com/pdtpartners/nix-snapshotter).

This will significantly reduce data duplication and the time it takes to pull images.

## Docker Compose with Nix

[Arion](https://docs.hercules-ci.com/arion/) is created for running Nix-based projects in Docker Compose. It uses the NixOS module system for configuration, it can bypass `docker build` and lets you use dockerTools or use the store directly in the containers. The images/containers can be typical dockerTools style images or full NixOS configs.

To use Arion, you first need to add its module to you NixOS configuration:

```
modules = [ arion.nixosModules.arion ];

```

After that you can access its options under

```
virtualisation.arion = {}

```

A config for a simple container could look like this:

```
virtualisation.arion = {
  backend = "docker";
  projects = {
    "db".settings.services."db".service = {
      image = "";
      restart = "unless-stopped";
      environment = { POSTGRESS_PASSWORD = "password"; };
    };
  };
};

```

## Using Nix in containers

While [dockerTools](https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-dockerTools) allows to build lightweight containers, it requires `nix` to be installed on the host system. An alternative are docker images with nix preinstalled:

-   [nixos/nix](https://hub.docker.com/r/nixos/nix/tags) (official)
-   [nixpkgs/nix](https://hub.docker.com/r/nixpkgs/nix) (built from [https://github.com/nix-community/docker-nixpkgs](https://github.com/nix-community/docker-nixpkgs))

## GPU Pass-through (Nvidia)

To enable GPU pass-through for for docker containers first you will need to enable `hardware.nvidia-container-toolkit.enable = true;` since `virtualisation.docker.enableNvidia = true;` is deprecated. Then when you run a container that you want to have the GPU pass-through you will need to use `--device=nvidia.com/gpu=all` since `gpu=all` does not work on NixOS. Assuming that you already have your GPU drivers installed for your computer you should have the container running with GPU pass-through.

**Note:** On laptops, rootless docker may cause issues when trying to enable GPU pass-through. On laptops, it is better to make docker super user only or to add yourself as a sudo user for docker.

## See also

[Workgroup:Container](https://nixos.wiki/wiki/Workgroup:Container "Workgroup:Container")

Alternatively you can use [Podman](https://nixos.wiki/wiki/Podman).