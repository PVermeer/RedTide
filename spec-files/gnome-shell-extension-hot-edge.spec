%global extension   hotedge
%global author      jonathan.jdoda.ca
%global repo        https://github.com/jdoda/hotedge
%global license     GPL-3.0-or-later
%global uuid        %{extension}@%{author}

Name:           gnome-shell-extension-%{extension}
Version:        32
Release:        1.redtide%{?dist}
BuildArch:      noarch
Summary:        Add a hot edge that activates the overview to the bottom of the screen.
License:        %{license}
URL:            %{repo}

Source:         %{extension}%{author}.v%{version}.shell-extension.zip

BuildRequires:  glib2
BuildRequires:  gettext
Requires:       gnome-shell >= 51
Provides:       %{extension} = %{version}-%{release}

%description
Add a hot edge that activates the overview to the bottom of the screen. This provides a better mouse-based workflow and can be an alternative to a dock.

%prep
%autosetup -c

%install
install -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -a . %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/

glib-compile-schemas --strict %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
# %license LICENSE # No license file in zip
%{_datadir}/gnome-shell/extensions/%{uuid}/
