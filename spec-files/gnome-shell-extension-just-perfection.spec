%global extension   just-perfection-desktop
%global author      just-perfection
%global repo        https://gitlab.gnome.org/jrahmatzadeh/just-perfection
%global license     GPL-3.0-only
%global uuid        %{extension}@%{author}

Name:           gnome-shell-extension-%{extension}
Version:        37
Release:        1.redtide%{?dist}
BuildArch:      noarch
Summary:        Tweak Tool to Customize GNOME Shell, Change the Behavior and Disable UI Elements.
License:        %{license}
URL:            %{repo}

Source:         %{extension}%{author}.v%{version}.shell-extension.zip

BuildRequires:  glib2
BuildRequires:  gettext
Requires:       gnome-shell >= 51
Provides:       %{extension} = %{version}-%{release}

%description
Tweak Tool to Customize GNOME Shell, Change the Behavior and Disable UI Elements.

%prep
%autosetup -c

%install
install -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -a . %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

glib-compile-schemas --strict %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/
