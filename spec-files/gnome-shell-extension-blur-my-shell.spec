%global extension   blur-my-shell
%global author      aunetx
%global repo        https://github.com/aunetx/blur-my-shell
%global license     GPL-3.0-or-later
%global uuid        %{extension}@%{author}

Name:           gnome-shell-extension-%{extension}
Version:        77
Release:        1.redtide%{?dist}
BuildArch:      noarch
Summary:        Adds a blur look to different parts of the GNOME Shell
License:        %{license}
URL:            %{repo}

Source:         %{extension}%{author}.v%{version}.shell-extension.zip

BuildRequires:  glib2
BuildRequires:  gettext
Requires:       gnome-shell >= 51
Provides:       %{extension} = %{version}-%{release}

%description
Adds a blur look to different parts of the GNOME Shell, including the top
panel, dash and overview.

%prep
%autosetup -c

%install
install -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -a . %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

glib-compile-schemas --strict %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/
