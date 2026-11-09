%global extension   caffeine
%global author      patapon.info
%global uuid        %{extension}@%{author}

Name:           gnome-shell-extension-%{extension}
Version:        61
Release:        1.redtide%{?dist}
BuildArch:      noarch
Summary:        Disable the screen saver and auto suspend in gnome shell
License:        GPL-2.0-only
URL:            https://github.com/eonpatapon/gnome-shell-extension-caffeine

Source:         %{extension}%{author}.v%{version}.shell-extension.zip

BuildRequires:  glib2
BuildRequires:  gettext
Requires:       gnome-shell >= 51
Provides:       %{extension} = %{version}-%{release}
	
%description
This extension allows the user to easily disable the screen saver and auto
suspend in gnome shell via an icon in the top bar. By default, this function
is also enabled if a full screen application is running, and can be configured
to disable gnome shell's night light as well.

%prep
%autosetup -c

%install
install -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -a . %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

glib-compile-schemas --strict %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
# %license COPYING No license in gnome-extension zip
%{_datadir}/gnome-shell/extensions/%{uuid}/
