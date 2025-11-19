dnl
dnl _AX_CHECK_VERSION()
dnl   $1 = command to be tested
dnl   $2 = action if "--version" is supported
dnl   $3 = action if "--version" is not supported
dnl
AC_DEFUN([_AX_CHECK_VERSION],[
  ax_have_version=no
  for opt_ver in "--version" "-v" "-V"
  do
    ax_have_version=`($1 $opt_ver 1>/dev/null 2>/dev/null </dev/null && echo yes) || echo no`
    ax_cv_version=`$1 $opt_ver 2>&1 | head -1 | tr "\t" " "`
    ax_cv_version_lower=`echo ${ax_cv_version} | tr ' A-Z[[]](){}' '_a-z______'`
    if test "x${ax_have_version}" = xyes -a "x${ax_cv_version}" != x
    then
      break
    fi
  done

  if test "x${ax_have_version}" = xyes
  then
    ax_cv_version_has_gnu=no
    ax_cv_version_has_llvm=no
    ax_cv_version_has_bsd=no
    ax_cv_version_has_apple=no
    ax_cv_version_has_microsoft=no
    case "${ax_cv_version_lower}" in
      *gnu*) ax_cv_version_has_gnu=yes ;;
      *bsd*) ax_cv_version_has_bsd=yes ;;
      *llvm*) ax_cv_version_has_llvm=yes;;
      *apple*) ax_cv_version_has_apple=yes;;
      *microsoft*) ax_cv_version_has_microsoft=yes;;
    esac
    ax_cv_version_number=`echo ${ax_cv_version} | sed -n 's/.* \([[0-9]][[0-9.]]*\).*/\1/p'`
    $2
  else
    :
    $3
  fi
])


dnl
dnl AX_CHECK_TAR_IS_GNU_1_12()
dnl   $1 = command to be tested
dnl   $2 = action if found to be GNU tar >= 1.12
dnl   $3 = action if not
dnl
AC_DEFUN([AX_CHECK_TAR_IS_GNU_1_12],[
  ax_tar_is_gnu_1_12=no
  AC_MSG_CHECKING([whether tar is GNU tar 1.12 or later])
  _AX_CHECK_VERSION([$1],[
      if test "x${ax_cv_version_has_gnu}" = xyes
      then
        ax_gtar_version_major=`echo ${ax_cv_version_number} | cut -f1 -d.`
        ax_gtar_version_minor=`echo ${ax_cv_version_number} | cut -f2 -d.`
        if test ${ax_gtar_version_major} -gt 1
        then
          ax_tar_is_gnu_1_12=yes
        elif test ${ax_gtar_version_major} -eq 1 -a ${ax_gtar_version_minor} -ge 12
        then
          ax_tar_is_gnu_1_12=yes
        fi
      fi
    ])
  if test "x${ax_tar_is_gnu_1_12}" = xyes
  then
    AC_MSG_RESULT([yes, ${ax_cv_version_number}])
    $2
  else
    AC_MSG_RESULT([no])
    $3
  fi
])


dnl
dnl AX_CHECK_TAR_IS_GNU_1_12_OR_BSDTAR()
dnl   $1 = command to be tested
dnl   $2 = action if found to be GNU tar >= 1.12
dnl   $3 = action if not
dnl
AC_DEFUN([AX_CHECK_TAR_IS_GNU_1_12_OR_BSDTAR],[
  ax_tar_is_gnu_1_12_or_bsdtar=no
  AC_MSG_CHECKING([whether $1 is GNU tar 1.12 or later, or libarchive bsdtar])
  _AX_CHECK_VERSION([$1],[
      if test "x${ax_have_version}" != xyes
      then
        :
      else
        case "x${ax_cv_version_lower}" in
          *gnu*tar*)
            ax_gtar_version_major=`echo ${ax_cv_version_number} | cut -f1 -d.`
            ax_gtar_version_minor=`echo ${ax_cv_version_number} | cut -f2 -d.`
            if test ${ax_gtar_version_major} -gt 1
            then
              AC_MSG_RESULT([yes, GNU tar ${ax_cv_version_number}])
              ax_tar_is_gnu_1_12_or_bsdtar=yes
            elif test ${ax_gtar_version_major} -eq 1 -a ${ax_gtar_version_minor} -ge 12
            then
              AC_MSG_RESULT([yes, GNU tar ${ax_cv_version_number}])
              ax_tar_is_gnu_1_12_or_bsdtar=yes
            fi
            ;;
          *bsdtar*libarchive*)
            AC_MSG_RESULT([yes, libarchive bsdtar ${ax_cv_version_number}])
            ax_tar_is_gnu_1_12_or_bsdtar=yes
            ;;
          *)
            ;;
        esac
      fi
    ])
  if test "x${ax_tar_is_gnu_1_12_or_bsdtar}" = xyes
  then
    :
    $2
  else
    AC_MSG_RESULT([no])
    $3
  fi
])



dnl
dnl AX_CHECK_TAR_MAGIC()
dnl   $1 = command to be tested, like "tar cf - conftest.txt"
dnl   $2 = file to be removed after test, like "conftest.txt"
dnl   $3 = action if output is ustar
dnl   $4 = action if output is not ustar
dnl
AC_DEFUN([AX_CHECK_TAR_MAGIC],[
  ax_tar_magic=`$1 | od -c -A n -j 257 -N 5 | tr -d " "`
  ax_tar_version=`$1 | od -t x1 -A n -j 263 -N 2 | tr -d " "`
  rm -f $2
  if test "x${ax_tar_magic}" = "xustar" -a "x${ax_tar_version}" = "x3030"
  then
    :
    $3
  else
    :
    $4
  fi
])


dnl
dnl AX_CHECK_TAR_SYMLINK()
dnl   $1 = command to be tested, like, "tar chf - conftest.lnk"
dnl   $2 = file to be removed after test, like "conftest.lnk"
dnl   $3 = action if output has no symlink
dnl   $4 = action if output keeps symlink
dnl
dnl NOTE: this macro does not check "ln -s" availability.
dnl
AC_DEFUN([AX_CHECK_TAR_SYMLINK],[
  touch $2
  ax_real_txt=`mktemp ax_real_XXXXXX.txt`
  echo real > "${ax_real_txt}"
  rm -f $2
  ln -s "${ax_real_txt}" $2
  ax_tar_typeflag=`$1 | od -A n -j 156 -c -N 1 | tr -d " "`
  rm -f "${ax_real_txt}" $2
  if test "x${ax_tar_typeflag}" = "x0"
  then
    :
    $3
  else
    :
    $4
  fi
])



dnl
dnl AX_GNUTAR_OUTPUT_USTAR
dnl   $1 = command to be tested, without option
dnl   $2 = action if given command generates ustar
dnl   $3 = action if we cannot found an option to generate ustar
dnl
dnl NOTE: Both of "--dereference" and "-h" are available in
dnl       GNU tar to archive without symbolic links.
dnl       However, "-h" is prioritized for the historical reason
dnl       that it has been used since pre-GNU era, like 4.2cBSD.
dnl       just after the introduction of symbolic link in 4.1aBSD.
dnl
AC_DEFUN([AX_GNUTAR_OUTPUT_USTAR],[
  AC_MSG_CHECKING([whether $1 is GNU tar with '--format=ustar' and '-h'])
  ax_cv_gnutar=yes
  tf=`mktemp ax_gnutar_real_XXXXXX.txt`
  AX_CHECK_TAR_MAGIC(  [$1 c --format=ustar -f - $tf],[$tf],[
    tf=`mktemp ax_gnutar_link_XXXXXX.lnk`
    AX_CHECK_TAR_SYMLINK([$1 c --format=ustar -h -f - $tf],[$tf],[ax_cv_gnutar=yes])
  ],[ax_cv_gnutar=no])
  if test "x${ax_cv_gnutar}" = xyes
  then
    AC_MSG_RESULT([yes])
    $2
  else
    AC_MSG_RESULT([no])
    $3
  fi
])


dnl
dnl AX_BSDTAR_OUTPUT_USTAR
dnl   $1 = command to be tested
dnl   $2 = action if given command generates ustar
dnl   $3 = action if we cannot found an option to generate ustar
dnl
dnl NOTE: Both of "--dereference" and "-h" are available in
dnl       libarchive's "bsdtar" to archive without symbolic links.
dnl       However, "-h" is prioritized for the historical reason
dnl       that it has been used since pre-libarchive era, like 4.2cBSD.
dnl       just after the introduction of symbolic link in 4.1aBSD.
dnl
AC_DEFUN([AX_BSDTAR_OUTPUT_USTAR],[
  AC_MSG_CHECKING([whether $1 is BSD tar with '--format ustar' and '-h'])
  ax_cv_bsdtar=yes
  tf=`mktemp ax_bsdtar_real_XXXXXX.txt`
  AX_CHECK_TAR_MAGIC([$1 c --format ustar -f - $tf],[$tf],[
    tf=`mktemp ax_bsdtar_link_XXXXXX.lnk`
    AX_CHECK_TAR_SYMLINK([$1 c --format ustar -h -f - $tf],[$tf],[ax_cv_bsdtar=yes])
  ],[ax_cv_bsdtar=no])
  if test "x${ax_cv_bsdtar}" = xyes
  then
    AC_MSG_RESULT([yes])
    $2
  else
    AC_MSG_RESULT([no])
    $3
  fi
])


dnl
dnl AX_TAR_OUTPUT_USTAR
dnl   $1 = command to be tested
dnl   $2 = action if given command generates ustar
dnl   $3 = action if we cannot found an option to generate ustar
dnl
dnl NOTE: Genuine BSD systems had never supported POSIX ustar
dnl       by tar command. It was supported by pax command.
dnl       SystemV (since Release 4) switched the default format
dnl       of tar command from old V7 format to POSIX ustar,
dnl       some systems had an option to handle old V7 format,
dnl       but default format of all systems are POSIX ustar.
dnl
dnl       Therefore, except of GNU tar and bsdtar (of libarchive),
dnl       there is no "tar" whose default is not ustar but
dnl       has an option to emit ustar.
dnl
dnl       Like Dell Unix SVR4 2.2, SystemV R4 source is supposed
dnl       to include "tar" source code supporting both of "-h"
dnl       and "-L", but famous proprietary systems based on
dnl       SystemV R4 did not support "-L" (like Solaris, HP-UX)
dnl       or used it for different purpose (like AIX).
dnl       Although tar is not a part of SVID3. In SVID4 (for
dnl       SystemV Release 4.2), tar was introduced with -L option
dnl       https://www.sco.com/developers/devspecs/vol2.pdf#264
dnl       UnixWare supported both of "-h" and "-L" options.
dnl
AC_DEFUN([AX_TAR_OUTPUT_USTAR],[
  AC_MSG_CHECKING([whether $1 is SysVR4 tar with '-h'])

  ax_cv_tar=yes
  unset ax_cv_tar_deref

  tf=`mktemp ax_tar_real_XXXXXX.txt`
  AX_CHECK_TAR_MAGIC([$1 c -f - $tf],[$tf],[
    tf=`mktemp ax_tar_link_XXXXXX.lnk`
    AX_CHECK_TAR_SYMLINK([$1 c -h -f - $tf],[$tf],[ax_cv_tar_deref="-h"],[
      tf=`mktemp ax_tar_link_XXXXXX.lnk`
      AX_CHECK_TAR_SYMLINK([$1 c -L -f - $tf],[$tf],[ax_cv_tar_deref="-L"],[ax_cv_tar=no])
    ])
  ],[ax_cv_tar=no])

  if test -n "${ax_cv_tar_deref}"
  then
    AC_MSG_RESULT([yes])
    $2
  else
    AC_MSG_RESULT([no])
    $3
  fi
])


dnl
dnl AX_PAX_OUTPUT_USTAR
dnl   $1 = command to be tested, without option
dnl   $2 = action if given command generates ustar
dnl   $3 = action if given command cannot generate ustar
dnl
AC_DEFUN([AX_PAX_OUTPUT_USTAR],[
  AC_MSG_CHECKING([whether $1 is pax with '-x ustar' and '-L'])

  tf=`mktemp ax_pax_real_XXXXXX.txt`
  AX_CHECK_TAR_MAGIC([$1 -w -x ustar -L -f - $tf],[$tf],[
    tf=`mktemp ax_pax_link_XXXXXX.lnk`
    AX_CHECK_TAR_SYMLINK([$1 -w -x ustar -L -f - $tf],[$tf],
                         [ax_cv_pax=yes],[ax_cv_pax=no])
  ],[ax_cv_pax=no])
  if test "x${ax_cv_pax}" = xyes
  then
    AC_MSG_RESULT([yes])
    $2
  else
    AC_MSG_RESULT([no])
    $3
  fi
])


dnl
dnl AX_CPIO_OUTPUT_USTAR
dnl   $1 = command to be tested, without option
dnl   $2 = action if given command generates ustar
dnl   $3 = action if we cannot found an option to generate ustar
dnl
AC_DEFUN([AX_CPIO_OUTPUT_USTAR],[
  AC_MSG_CHECKING([whether $1 is GNU or SysVR4 cpio with '-H ustar' and '-L'])

  tf=`mktemp ax_cpio_real_XXXXXX.txt`
  AX_CHECK_TAR_MAGIC([echo $tf | $1 -o -H ustar 2>/dev/null],[$tf],[
    tf=`mktemp ax_cpio_link_XXXXXX.lnk`
    AX_CHECK_TAR_SYMLINK([echo $tf | $1 -o -H ustar -L 2>/dev/null],[$tf],
      [ax_cv_cpio=yes],[ax_cv_cpio=no])
  ],[ax_cv_cpio=no])
  if test "x${ax_cv_cpio}" = xyes
  then
    AC_MSG_RESULT([yes])
    $2
  else
    AC_MSG_RESULT([no])
    $3
  fi
])


dnl
dnl AX_CMD_USTAR
dnl   $1 = space separated list of commands to be tested
dnl   $2 = action with first command generating ustar
dnl   $3 = action with no command is found
dnl
AC_DEFUN([AX_CMD_USTAR],[
  AC_PATH_PROGS([ax_cmd_ustar_candidates],[$1])
  for ax_cv_cmd in ${ax_cmd_ustar_candidates}
  do
    case "${ax_cv_cmd}" in
    *gnutar|*gtar)
      AX_GNUTAR_OUTPUT_USTAR([$ax_cv_cmd],[
          ax_cv_cmd="${ax_cv_cmd} c --format=ustar -h -f -"
        ],[unset ax_cv_cmd])
      ;;
    *bsdtar)
      AX_BSDTAR_OUTPUT_USTAR([$ax_cv_cmd],[
          ax_cv_cmd="${ax_cv_cmd} c --format ustar -h -f -"
        ],[unset ax_cv_cmd])
      ;;
    *tar)
      AX_TAR_OUTPUT_USTAR([$ax_cv_cmd],[
          ax_cv_cmd="${ax_cv_cmd} c ${ax_cv_tar_deref} -f -"
        ],[unset ax_cv_cmd])
      ;;
    *pax)
      AX_PAX_OUTPUT_USTAR([$ax_cv_cmd],[
          ax_cv_cmd="${ax_cv_cmd} -w -x ustar -L -f -"
        ],[unset ax_cv_cmd])
      ;;
    *cpio)
      AX_CPIO_OUTPUT_USTAR([$ax_cv_cmd],[
          ax_cv_cmd="${ax_cv_cmd} -o -H ustar -L"
        ],[unset ax_cv_cmd])
      ;;
    *)
      AC_MSG_WARN([testing for "${ax_cv_cmd}" is unknown, ignored])
      unset ax_cv_cmd
      ;;
    esac
    if test -n "${ax_cv_cmd}"
    then
      break
    fi
    unset ax_cv_cmd
  done
  AS_IF([test -n "${ax_cv_cmd}"],[$2],[$3])
])
