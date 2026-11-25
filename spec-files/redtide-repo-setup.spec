Name: redtide-repo-setup
Version: 0.0.1
Release: 0%{?dist}
License: GPL-3.0-only
Summary: Setup RedTide repo
Url: https://github.com/PVermeer/RedTide

Source0: redtide.conf
Source1: ostree-redtide.pub
Source2: 90-redtide-repo-setup.preset

BuildRequires: systemd-rpm-macros

%description
The repo setup for RedTide community Silverblue image.
This installs the ostree repo and the public signing keys.

%install
install -Dm0644 %{SOURCE0} %{buildroot}/%{_sysconfdir}/ostree/remotes.d/redtide.conf
install -Dm0644 %{SOURCE1} %{buildroot}/%{_sysconfdir}/ostree/remotes.d/ostree-redtide.pub
install -Dm0644 %{SOURCE2} %{buildroot}%{_presetdir}/90-redtide-repo-setup.preset

%pre
if ! grep -qFx '#AutomaticUpdatePolicy=none' %{_sysconfdir}/rpm-ostreed.conf; then
    echo "ERROR: Expected '#AutomaticUpdatePolicy=none' in rpm-ostreed.conf"
    exit 1
fi

sed -i 's/^#AutomaticUpdatePolicy=none$/AutomaticUpdatePolicy=stage/' %{_sysconfdir}/rpm-ostreed.conf

if ! grep -qFx 'AutomaticUpdatePolicy=stage' %{_sysconfdir}/rpm-ostreed.conf; then
    echo "ERROR: Failed to set AutomaticUpdatePolicy=stage"
    exit 1
fi

%post
%systemd_post rpm-ostreed-automatic.timer

%preun
%systemd_preun rpm-ostreed-automatic.timer

%postun
%systemd_postun rpm-ostreed-automatic.timer

%files
%{_sysconfdir}/ostree/remotes.d/redtide.conf
%{_sysconfdir}/ostree/remotes.d/ostree-redtide.pub
%{_presetdir}/90-redtide-repo-setup.preset
