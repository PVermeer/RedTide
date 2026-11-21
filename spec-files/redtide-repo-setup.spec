Name: redtide-repo-setup
Version: 0.0.1
Release: 0%{?dist}
License: GPL-3.0-only
Summary: Setup RedTide repo
Url: https://github.com/PVermeer/RedTide

Source0: redtide.conf
Source1: ostree-redtide.pub
Source2: service

BuildRequires: systemd-rpm-macros

%description
The repo setup for RedTide community Silverblue image.
This installs the ostree repo and the public signing keys.

%prep
if [ "$(date +%s)" -gt "$(date -d '2027-02-21' +%s)" ]; then
    echo "ERROR: Temporary RedTide rebase to ostree commit signed has expired."
    echo "ERROR: Remove it from this build!"

    exit 1
fi

%install
install -Dm0644 %{SOURCE0} %{buildroot}/%{_sysconfdir}/ostree/remotes.d/redtide.conf
install -Dm0644 %{SOURCE1} %{buildroot}/%{_sysconfdir}/ostree/remotes.d/ostree-redtide.pub

install -Dm0644 %{SOURCE2}/redtide-repo-setup.service %{buildroot}/%{_unitdir}/redtide-repo-setup.service
install -Dm0644 %{SOURCE2}/90-redtide-repo-setup.preset %{buildroot}/%{_prefix}/lib/systemd/system-preset/90-redtide-repo-setup.preset
install -Dm0755 %{SOURCE2}/redtide-repo-setup %{buildroot}/%{_libexecdir}/redtide/redtide-repo-setup

%post
%systemd_post redtide-repo-setup.service

%preun
%systemd_preun redtide-repo-setup.service

%postun
%systemd_postun redtide-repo-setup.service

%files
%{_sysconfdir}/ostree/remotes.d/redtide.conf
%{_sysconfdir}/ostree/remotes.d/ostree-redtide.pub

%{_unitdir}/redtide-repo-setup.service
%{_prefix}/lib/systemd/system-preset/90-redtide-repo-setup.preset
%{_libexecdir}/redtide/redtide-repo-setup
