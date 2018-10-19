pkglib_LTLIBRARIES = libasyncprocess.la
libasyncprocess_la_LDFLAGS = -module -avoid-version -no-undefined
libasyncprocess_la_SOURCES = src/async-process.c src/async-process_windows.c

libasync_abiversion=0

src/async-process.c: src/gend.h
copy: $(pkglib_LTLIBRARIES)
	cp -f .libs/libasyncprocess.so static/libasyncprocess-`uname -m`-`uname`-$(libasync_abiversion).so|true
	cp -f .libs/libasyncprocess.dylib static/libasyncprocess-`uname -m`-`uname`-$(libasync_abiversion).dylib|true
	case "$(MSYSTEM)" in \
	  MINGW32)           \
	    cp -f .libs/libasyncprocess.dll static/libasyncprocess-x86-$(libasync_abiversion).dll|true;; \
	  *)                 \
	    cp -f .libs/libasyncprocess.dll static/libasyncprocess-`uname -m`-$(libasync_abiversion).dll|true;; \
	esac

FORCE:

src/gend.h: FORCE
	(printf "#define GIT_REVISION \"" && ((which git>/dev/null&&[ -e .git ]&& \
	(git log -n 1 --oneline|cut -d' ' -f1| tr -d '\n'| tr -d '\r'))||printf "") && printf "\"\n") > $@.tmp
	cmp -s $@.tmp $@||cp $@.tmp $@
	cat $@
	rm -f $@.tmp
