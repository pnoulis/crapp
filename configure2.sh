#!/usr/bin/env bash
declare -g host_gnu_prefix \
    host_exec_prefix \
    host_libexecdir \
    host_localstatedir \
    host_datarootdir \
    host_sysconfdir \
    host_bindir \
    host_sbindir \
    host_libdir \
    host_localedir \
    host_includedir \
    host_oldincludedir \
    host_docdir \
    host_infodir \
    host_lispdir \
    host_mandir

set_installdirs() {
    case "${INSTALL_PRESET:-}" in
    vendor-systemd)
        # Prefixes
        co_prefix=/usr
        co_execprefix=${co_prefix}
        # Executables
        co_bindir=${co_execprefix}/bin
        co_sbindir=${co_execprefix}/sbin
        # Configuration
        co_sysconfdir=/etc
        # Variable persistent data
        co_localstatedir=/var
        # Transient data
        co_runstatedir=/run
        # Libraries and static data
        co_librootdir=${co_prefix}/lib
        co_libdatadir=${co_librootdir}/${pkg_name}
        co_libarchdir=${co_librootdir}/$(systemd-path system-library-arch)
        co_libexecdir=${co_libdatadir}
        # Headers
        co_includedir=${co_prefix}/include
        # Documentation
        set_datadirs
        # Derived dirs
        set_derivedirs
        # User runtime dirs
        set_usruntimedirs
        ;;
    vendor-gnu)
        host_prefix=/usr
        host_exec_prefix=${host_prefix}
        host_bindir=${host_exec_prefix}/bin
        host_sbindir=${host_exec_prefix}/sbin
        host_libdir=${host_exec_prefix}/lib/${pkg_name}
        ;;
    admin-systemd)
        host_prefix=/usr/local
        host_exec_prefix=${host_prefix}
        host_bindir=${host_exec_prefix}/bin
        host_sbindir=${host_exec_prefix}/sbin
        ;;
    admin) ;;

    optional)
        host_prefix=/opt/${pkg_name}
        host_exec_prefix=${host_prefix}
        host_bindir=${host_exec_prefix}/bin
        host_sbindir=${host_exec_prefix}/sbin
        ;;
    user-xdg)
        host_prefix=${HOME}
        host_exec_prefix=${host_prefix}
        host_bindir=${host_exec_prefix}/.local/bin
        host_sbindir=${host_exec_prefix}/.local/sbin
        ;;
    user)
        host_prefix=${HOME}
        host_exec_prefix=${host_prefix}
        host_bindir=${host_exec_prefix}/bin
        host_sbindir=${host_exec_prefix}/sbin
        ;;
    *) ;;
    esac
}

set_usruntimedirs() {
    co_usrcachedir=${XDG_CACHE_HOME:-${HOME}/.cache}
    co_usrconfdir=${XDG_CONFIG_HOME:-${HOME}/.config}
    co_usrdatadir=${XDG_DATA_HOME:-${HOME}/.local/share}
    co_usrstatedir=${XDG_STATE_HOME:-${HOME}/.local/state}
    co_usrundir=${XDG_RUNTIME_DIR:-/var/run/$(id -u)}
    co_usrlibdir=${HOME}/.local/lib
    co_usrlibarchdir=${HOME}/.local/lib/$(systemd-path system-library-arch)
    co_usrbindir=${HOME}/.local/bin
}
set_datadirs() {
    co_datarootdir=${host_prefix}/share
    co_datadir=${host_datarootdir}/${pkg_name}
    co_mandir=${host_datarootdir}/man
    co_docdir=${host_datarootdir}/doc/${pkg_name}
    co_infodir=${host_datarootdir}/info
    co_htmldir=${host_docdir}/html
    co_pdfdir=${host_docdir}/pdf
}
set_derivedirs() {
    co_sysstatedir=${co_localstatedir}/lib
    co_syslogdir=${co_localstatedir}/log
    co_syscachedir=${co_localstatedir}/cache
    co_syspooldir=${co_localstatedir}/spool
}
