Name: redtide-repo-setup
Version: 0.0.1
Release: 0%{?dist}
License: GPL-3.0-only
Summary: Setup RedTide repo
Url: https://github.com/PVermeer/RedTide

Source0: redtide.conf
Source1: ostree-redtide.pub

BuildRequires: systemd-rpm-macros

%description
The repo setup for RedTide community Silverblue image.
This installs the ostree repo and the public signing keys.

%install
install -Dm0644 %{SOURCE0} %{buildroot}/%{_sysconfdir}/ostree/remotes.d/redtide.conf
install -Dm0644 %{SOURCE1} %{buildroot}/%{_sysconfdir}/ostree/remotes.d/ostree-redtide.pub

%files
%{_sysconfdir}/ostree/remotes.d/redtide.conf
%{_sysconfdir}/ostree/remotes.d/ostree-redtide.pub
