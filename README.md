## Perimeter81 Nix Flake

Attempt to repackage [perimeter81.deb](https://support.perimeter81.com/docs/downloading-the-agent) to Nix.
This project provides a Nix flake to package and run the Perimeter81 VPN client on NixOS or other Linux distributions using Nix.

## Features

- Repackages the Perimeter81 `.deb` file for use with Nix.
- Provides a NixOS module for easy integration.

## Prerequisites

- Nix installed on your system.
- Flakes enabled in your Nix configuration.

## Usage


### Using the NixOS Module

1. Add this flake to your NixOS configuration:

    ```nix
    {
      inputs.perimeter81.url = "github:devusb/p81.nix";
      outputs = { self, nixpkgs, perimeter81, ... }: {
        nixosConfigurations.mySystem = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
            perimeter81.nixosModules.perimeter81
          ];
        };
      };
    }
    ```

2. Enable the perimeter81 service in your `configuration.nix`:

    ```nix
    {
      services.perimeter81.enable = true;
    }
    ```

3. Rebuild your NixOS system:

    ```bash
    sudo nixos-rebuild switch
    ```

### Running the Perimeter81 Client

After installation, you can run the Perimeter81 client using:

    ```bash
    perimeter81
    ```

### Running Perimeter81 on Nix

1. Clone this repository
2. Build and run the Perimeter81 package:

    ```bash
    nix run .#perimeter81
    ```

## Troubleshooting

### Common Issues

#### Service Fails to Start
- Check the logs for the `perimeter81-helper-daemon` service:
    ```bash
    journalctl -u perimeter81-helper-daemon
    ```
- Ensure that the `.deb` file URL and checksum in `perimeter81.nix` are correct and up-to-date.

#### Missing Dependencies
- Verify that all required libraries and dependencies are included in the FHS environment. Update the `extraPkgs` or `extraLibs` in `fhsenv.nix` if necessary.

#### Network Issues
- Ensure your system has active network connectivity.
- Verify that `NetworkManager` and `systemd-resolved` services are running:
    ```bash
    systemctl status NetworkManager
    systemctl status systemd-resolved
    ```

### Debugging Tips
- Run the client manually in the FHS environment to debug:
    ```bash
    nix run .#perimeter81 --command bash
    ```
- Check the system journal for additional logs:
    ```bash
    journalctl -xe
    ```
