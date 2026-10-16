Name: redtide-setup
Version: 0.0.1
Release: 0%{?dist}
License: GPL-3.0 license
Summary: Setup anything with actions
Url: https://github.com/PVermeer/RedTide

Source0: redtide-setup.desktop
Source1: config.yml
Source2: pages

BuildRequires: systemd-rpm-macros
BuildRequires: desktop-file-utils

Requires: any-setup

%description
The user setup application for RedTide using any-setup

%prep

%build

%install
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/any-setup/pages

install -Dm0644 %{SOURCE0} %{buildroot}%{_datadir}/applications/redtide-setup.desktop
install -Dm0644 %{SOURCE1} %{buildroot}%{_datadir}/any-setup/config.yml

for page_config in %{SOURCE2}/*; do
    install -Dm0644 "$page_config" %{buildroot}%{_datadir}/any-setup/pages/
done

%check
desktop-file-validate %{buildroot}%{_datadir}/applications/redtide-setup.desktop

%files
%{_datadir}/applications/redtide-setup.desktop
%{_datadir}/any-setup/config.yml
%{_datadir}/any-setup/pages/*
