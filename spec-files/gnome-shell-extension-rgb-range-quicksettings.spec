%global extension   rgb-range-quicksettings
%global author      yofuness.github.io
%global repo        https://github.com/Yofuness/gnome-rgb-range
%global license     GPL-2.0-or-later
%global uuid        %{extension}@%{author}

Name:           gnome-shell-extension-%{extension}
Version:        1.0.0
Release:        1.redtide%{?dist}
BuildArch:      noarch
Summary:        RGB Range Quick Settings
License:        %{license}
URL:            %{repo}

Source0:        %{extension}%{author}.v%{version}.shell-extension.zip
Source1:        LICENSE

BuildRequires:  glib2
BuildRequires:  gettext
Requires:       gnome-shell >= 51
Provides:       %{extension} = %{version}-%{release}

%description
Switch a monitor's RGB quantization range (Auto, Full or Limited) from Quick Settings, using Mutter's Broadcast RGB support.

%prep
%autosetup -c
cp %{SOURCE1} LICENSE

%install
install -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -a . %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/
