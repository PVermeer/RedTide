Name: steamos
Version: 0.0.1
Release: 0.redtide%{?dist}
License: GPL-3.0-only
Summary: Launch steam as it would on steamOS on desktop or gamescope-session.
Url: %{sourcerepo}

Source0: LICENSE
Source1: gamescope-session
Source2: steam-steamos

Requires: steam
Requires: gamescope
Requires: mangohud
Requires: /usr/bin/gdctl

%description
A simple gamescope session for steam.
A launcher and desktop files to launch steam in steamOS mode.

%install
install -d %{buildroot}%{_licensedir}/%{name}
install -m 0644 %{SOURCE0} %{buildroot}/%{_licensedir}/%{name}/

# Gamescope session
install -d %{buildroot}/%{_bindir}/steamos-polkit-helpers
install -d %{buildroot}/%{_sysconfdir}/environment.d
install -d %{buildroot}/%{_datadir}/wayland-sessions
install -d %{buildroot}/%{_userunitdir}

install -m 0755 %{SOURCE1}/jupiter-biosupdate %{buildroot}/%{_bindir}/steamos-polkit-helpers/
install -m 0755 %{SOURCE1}/steamos-set-timezone %{buildroot}/%{_bindir}/steamos-polkit-helpers/
install -m 0755 %{SOURCE1}/steamos-update %{buildroot}/%{_bindir}/steamos-polkit-helpers/

install -m 0755 %{SOURCE1}/gamescope-session-steam %{buildroot}/%{_bindir}/
install -m 0755 %{SOURCE1}/steamos-select-branch %{buildroot}/%{_bindir}/
install -m 0755 %{SOURCE1}/steamos-session-select %{buildroot}/%{_bindir}/

install -m 0644 %{SOURCE1}/gamescope-session-steam.conf %{buildroot}/%{_sysconfdir}/environment.d/
install -m 0644 %{SOURCE1}/gamescope-session-steam.desktop %{buildroot}/%{_datadir}/wayland-sessions/
install -m 0644 %{SOURCE1}/gamescope-session.target %{buildroot}/%{_userunitdir}/

# Steam steamos
install -d %{buildroot}/%{_bindir}
install -d %{buildroot}/%{_datadir}/applications/

install -D -m 0755 %{SOURCE2}/steam-steamos %{buildroot}/%{_bindir}
install -D -m 0644 %{SOURCE2}/steam-steamos.desktop %{buildroot}/%{_datadir}/applications
install -D -m 0644 %{SOURCE2}/steam-steamos-gamescope.desktop %{buildroot}/%{_datadir}/applications

%files
%license %{_licensedir}/%{name}/LICENSE

# Gamescope session
%{_bindir}/steamos-polkit-helpers/jupiter-biosupdate
%{_bindir}/steamos-polkit-helpers/steamos-set-timezone
%{_bindir}/steamos-polkit-helpers/steamos-update

%{_bindir}/gamescope-session-steam
%{_bindir}/steamos-select-branch
%{_bindir}/steamos-session-select

%config(noreplace) %{_sysconfdir}/environment.d/gamescope-session-steam.conf
%{_datadir}/wayland-sessions/gamescope-session-steam.desktop
%{_userunitdir}/gamescope-session.target

# Steam steamos
%{_bindir}/steam-steamos
%{_datadir}/applications/steam-steamos.desktop
%{_datadir}/applications/steam-steamos-gamescope.desktop
