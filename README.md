# Redtide

> ⚠️ **Warning:** WIP!!!!

An unopiniated custom Fedora Silverblue image focussed on gaming and software development with the following principles:

- Stable and secure
- Stays close to Fedora
- Don't mess with user space (no crappy user scripts)

# Install

1. Download the Silverblue iso: https://fedoraproject.org/atomic-desktops/silverblue.
2. Install Silverblue.
3. Rebase to Redtide.
   ```sh
   rpm-ostree rebase ostree-unverified-registry:ghcr.io/pvermeer/redtide:stable
   ```

# Image variants

### Stable:

Stable image is upgraded from beta after at least two weeks of release. In between updates only contain hotfixes.

### Beta:

Beta image is updated every two weeks with Fedora Silverblue and contains fixes and new features from latest.

### Testing

Testing image is used for testing new features and can lag behind.

# Packages

Redtide contains a pretty standard setup with the `rpm-fusion` multimedia freeworld packages and the nvidia kernel module. If you think a package should be included please create an issue or PR.

## Software development

The aim for software development is to do this as much in dev-container that contain specialized libraries and tools. The image should contain tools and libraries to allow IDE's to open en analyze projects.

## Gaming

Gaming focusses on stability. So no cowboying all the latest (and buggy) technologies on the image too gain a very small performance increase. The aim is to stay as close as possible to Fedora so technologies follow a proper Q&A process.

## Notable packages:

See [packages](packages) for the full package install list.

### Gaming

| Package                 | Description                                                            | Source                                                                   |
| ----------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| gamescope-session-steam | Adds a gamescope session to the login                                  | [terra](https://terrapkg.com/)                                           |
| akmod-xonedo            | Kernel module for newer Xbox controllers with wireless adapter support | [terra](https://terrapkg.com/)                                           |
| akmod-xpadneo           | Kernel module for older Xbox controllers with bluetooth support        | [terra](https://terrapkg.com/)                                           |
| sunshine                | Self-hosted game stream host for Moonlight                             | [copr](https://copr.fedorainfracloud.org/coprs/pvermeer/sunshine)        |
| virtual-display         | A daemon and cli to enable/disable a (kernel) virtual display          | [copr](https://copr.fedorainfracloud.org/coprs/pvermeer/virtual-display) |

### Software development

| Package   | Description                                                       | Source                                                                |
| --------- | ----------------------------------------------------------------- | --------------------------------------------------------------------- |
| code      | Visual Studio Code                                                | [vscode](https://packages.microsoft.com/yumrepos/vscode)              |
| distrobox | Another tool for containerized command line environments on Linux | [fedora](https://packages.fedoraproject.org/pkgs/distrobox/distrobox) |
| docker-ce | The open-source application container engine                      | [docker](https://download.docker.com/linux/fedora)                    |
