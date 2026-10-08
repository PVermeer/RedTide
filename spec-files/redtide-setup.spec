Name: redtide-setup
Version: 0.0.1
Release: 0%{?dist}
License: GPL-3.0 license
Summary: Setup anything with actions
Url: https://github.com/PVermeer/RedTide

Source0: redtide-setup.desktop
Source1: config.yml
Source2: 00-home.yml
Source3: 01-gaming.yml
Source4: 02-development.yml

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
install -Dm0644 %{SOURCE1} %{buildroot}%{_datadir}/any-setup/
install -Dm0644 %{SOURCE2} %{buildroot}%{_datadir}/any-setup/pages/
install -Dm0644 %{SOURCE3} %{buildroot}%{_datadir}/any-setup/pages/
install -Dm0644 %{SOURCE4} %{buildroot}%{_datadir}/any-setup/pages/

%check
desktop-file-validate %{buildroot}%{_datadir}/applications/redtide-setup.desktop

%files
%{_datadir}/applications/redtide-setup.desktop
%{_datadir}/any-setup/config.yml
%{_datadir}/any-setup/pages/00-home.yml
%{_datadir}/any-setup/pages/01-gaming.yml
%{_datadir}/any-setup/pages/02-development.yml
