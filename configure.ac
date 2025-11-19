AC_PREREQ([2.70])
AC_INIT([ax-ustar], [0.0.20251118], [])
AM_INIT_AUTOMAKE([1.11 foreign])

AX_CHECK_TAR_IS_GNU_1_12_OR_BSDTAR([tar])

AX_CMD_USTAR([cpio pax tar],[
  TAR_CHF="${ax_cv_cmd}"
],[])

AC_SUBST([TAR_CHF])

AC_CONFIG_FILES([GNUmakefile])
AC_OUTPUT
