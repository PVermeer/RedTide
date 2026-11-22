%global extension   wireless-hid
%global author      chlumskyvaclav.gmail.com
%global repo        https://github.com/vchlum/wireless-hid
%global license     MIT
%global uuid        %{extension}@%{author}

Name:           gnome-shell-extension-%{extension}
Version:        24
Release:        1.redtide%{?dist}
BuildArch:      noarch
Summary:        This extension shows the battery of the wireless keyboards, mice, and game controllers in percentages and colors.
License:        %{license}
URL:            %{repo}

Source:         %{extension}%{author}.v%{version}.shell-extension.zip

BuildRequires:  glib2
BuildRequires:  gettext
Requires:       gnome-shell >= 51
Provides:       %{extension} = %{version}-%{release}

%description
This extension shows the battery of the wireless keyboards, mice, and game controllers in percentages and colors. Multiple devices are supported.

%prep
%autosetup -c

%install
install -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -a . %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

glib-compile-schemas --strict %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/
