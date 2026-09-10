# Redtide

> ⚠️ **Warning:** WIP!!!!

An unopinionated custom Fedora Silverblue image focused on gaming and software development with the following principles:

- Stable and secure
- Stays close to Fedora
- Don't mess with user space (no crappy user scripts)

# Install

1. Download the Silverblue ISO: https://fedoraproject.org/atomic-desktops/silverblue.
2. Install Silverblue.
3. Rebase to Redtide with the [rebase.sh](rebase.sh) script. The script configures the security keys for RedTide and rebases rpm-ostree to the RedTide stable image.

   ```sh
   # Download script
   wget https://raw.githubusercontent.com/pvermeer/redtide/main/rebase.sh

   # Set executable
   chmod +x rebase.sh

   # Run as root
   sudo ./rebase.sh
   ```

# Image variants

There are three channels: `stable`, `beta` and `testing`. The images are hosted on:

`ghcr.io/pvermeer/redtide:<channel>`

**Stable**

The stable image is promoted from the beta image at the end of the two-week merge window. Subsequent updates are limited to hotfixes until the next scheduled release.

**Beta**

The beta image is updated every two weeks with Fedora Silverblue and includes new features and fixes intended for the next stable release.

**Testing**

The testing image is used for testing fixes and new features. This image is built outside of the release pipeline and can lag behind.

# Packages

Redtide contains a pretty standard setup with the `rpm-fusion` multimedia freeworld packages and the NVIDIA kernel module. The aim of this project is to stay as close as possible to Fedora with a proper QA process while fully supporting gaming and development.

**Please open a PR or issue if you need something added**.

## Software development

The aim for software development is to do this in dev-containers that contain specialized libraries and tools. For this, Docker CE and Podman are available. The image should contain tools and libraries to allow IDEs to open and analyze projects.

## Gaming

Gaming focuses on stability. So no cowboying all the latest (and buggy) technologies on the image to gain a very small performance increase. The aim is to stay as close as possible to Fedora with a proper QA process.

## Notable packages

See [packages](packages) for the full package install list.

### Gaming

| Package                 | Description                                                            | Source                                                                   |
| ----------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| gamescope-session-steam | Adds a gamescope session to the login                                  | [terra](https://terrapkg.com/)                                           |
| akmod-xonedo            | Kernel module for newer Xbox controllers with wireless adapter support | [terra](https://terrapkg.com/)                                           |
| akmod-xpadneo           | Kernel module for older Xbox controllers with bluetooth support        | [terra](https://terrapkg.com/)                                           |
| sunshine                | Self-hosted game stream host for Moonlight                             | [copr](https://copr.fedorainfracloud.org/coprs/pvermeer/sunshine)        |
| virtual-display         | A daemon and CLI to enable/disable a (kernel) virtual display          | [copr](https://copr.fedorainfracloud.org/coprs/pvermeer/virtual-display) |

### Software development

| Package   | Description                                                       | Source                                                                |
| --------- | ----------------------------------------------------------------- | --------------------------------------------------------------------- |
| code      | Visual Studio Code                                                | [vscode](https://packages.microsoft.com/yumrepos/vscode)              |
| zed       | Zed is a high-performance, multiplayer code editor                | [terra](https://terrapkg.com/)                                        |
| distrobox | Another tool for containerized command line environments on Linux | [fedora](https://packages.fedoraproject.org/pkgs/distrobox/distrobox) |
| docker-ce | The open-source application container engine                      | [docker](https://download.docker.com/linux/fedora)                    |

# Release Pipeline

## Release Cycle

```text
beta
│
├── Two-week merge window
│ └── Changes merged into beta
│
└── Stable release
│
├── Merge beta → stable
│
├── Promote beta image
│ └── stable
│
└── Build new beta image
├── Include changes from merge window
└── Incorporate upstream changes
```

## Beta

The `beta` branch has a **two-week merge window** for changes intended for the next stable release.

During the merge window, changes are merged into `beta`.

At the end of the window, the beta image is built with the changes from the merge window and incorporates upstream changes.

## Stable Release

At the end of the two-week window, the release workflow:

1. Merges `beta` into `stable`.
2. Promotes the current beta image to `stable`.
3. Builds a new beta image with the changes from the completed merge window and incorporates upstream changes.

The release workflow runs every other Monday at 08:00 UTC and can also be triggered manually.

## Image / Git Relationship

Each image is associated with the Git commit it was built from.

Stable releases promote the existing beta image rather than rebuilding it.
