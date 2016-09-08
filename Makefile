CURL=curl-7.50.2
QRENCODE=qrencode-3.4.4
LUA=lua-5.2.4
WXVERSION=3.1.0
WX=wxWidgets-$(WXVERSION)
HARU=RELEASE_2_3_0
HARUDIR=libharu-$(HARU)
ZLIBVERSION=1.2.8
ZLIB=zlib-$(ZLIBVERSION)
PNGVERSION=1.6.25
PNG=libpng-$(PNGVERSION)

ROOTFS=$(PWD)/rootfs

CURLFILE=$(CURL).tar.bz2
QRENCODEFILE=$(QRENCODE).tar.bz2
LUAFILE=$(LUA).tar.gz
WXFILE=$(WX).tar.bz2
HARUFILE=$(HARU).zip
ZLIBFILE=$(ZLIB).tar.gz
PNGFILE=$(PNG).tar.gz

CURLURL=http://curl.haxx.se/download/$(CURLFILE)
QRENCODEURL=http://fukuchi.org/works/qrencode/$(QRENCODEFILE)
LUAURL=http://www.lua.org/ftp/$(LUAFILE)
WXURL=https://github.com/wxWidgets/wxWidgets/releases/download/v$(WXVERSION)/$(WXFILE)
HARUURL=https://github.com/libharu/libharu/archive/$(HARUFILE)
ZLIBURL=http://downloads.sourceforge.net/project/libpng/zlib/$(ZLIBVERSION)/$(ZLIBFILE)?r=\&ts=1454597029\&use_mirror=vorboss
PNGURL=http://downloads.sourceforge.net/project/libpng/libpng16/$(PNGVERSION)/$(PNGFILE)?r=\&ts=1473331135\&use_mirror=netix

CURLTARGET=$(ROOTFS)/lib/libcurl-4.dll
QRENCODETARGET=$(ROOTFS)/lib/libqrencode.a
LUATARGET=$(ROOTFS)/lib/lua52.dll
WXTARGET=$(ROOTFS)/lib/wxmsw310u_core_gcc_custom.dll
HARUTARGET=$(ROOTFS)/lib/libhpdf.a
ZLIBTARGET=$(ROOTFS)/lib/libz.a
PNGTARGET=$(ROOTFS)/lib/libpng.a

CURLCONFIG=CPPFLAGS="-I${ROOTFS}/include"\
	LDFLAGS="-L${ROOTFS}/lib"\
	./configure\
	--prefix=$(ROOTFS)\
	--host=i686-w64-mingw32\
	--enable-ipv6\
	--with-zlib=$(ROOTFS)\
	--with-winidn\
	--with-winssl\
	--without-zsh-functions-dir

QRENCODECONFIG=./configure\
	--host=i686-w64-mingw32\
	--without-tools\
	--prefix=$(ROOTFS)

LUACONFIG=\
	CC=i686-w64-mingw32-gcc\
	LUA_A=lua52.dll\
	LUA_T=lua.exe\
	PLAT=mingw\
	AR="i686-w64-mingw32-gcc -shared -o"\
	RANLIB="i686-w64-mingw32-strip --strip-unneeded"\
	MYCFLAGS=-DLUA_BUILD_AS_DLL\
	MYLIBS=\
	MYLDFLAGS=-s

WXCONFIG=CPPFLAGS="-I${ROOTFS}/include"\
	LDFLAGS="-L${ROOTFS}/lib"\
	../configure\
	--prefix=$(ROOTFS)\
	--host=i686-w64-mingw32\
	--build=i686-linux\
	--enable-unicode\
	--disable-stc\
	--with-msw\
	--without-subdirs

HARUCONFIG=./buildconf.sh --force && ./configure\
	--prefix=$(ROOTFS)\
	--host=i686-w64-mingw32\
	--with-png=$(ROOTFS)\
	--with-zlib=$(ROOTFS)

ZLIBCONFIG=CC=i686-w64-mingw32-gcc AR=i686-w64-mingw32-ar\
	RANLIB=i686-w64-mingw32-ranlib\
	LDSHAREDLIBC=\
	STATICLIB=libz.a\
	SHAREDLIB=zlib1.dll\
	IMPLIB=libz.dll.a\
	./configure\
	--prefix=$(ROOTFS)

PNGCONFIG=CPPFLAGS="-I${ROOTFS}/include"\
	LDFLAGS="-L${ROOTFS}/lib"\
	./configure\
	--prefix=$(ROOTFS)\
	--host=i686-w64-mingw32

all: $(CURLTARGET) $(QRENCODETARGET) $(LUATARGET) $(HARUTARGET) $(WXTARGET) $(PNGTARGET)
	echo Done

$(CURLFILE):
	wget -O $@ $(CURLURL)

$(QRENCODEFILE):
	wget -O $@ $(QRENCODEURL)

$(LUAFILE):
	wget -O $@ $(LUAURL)

$(WXFILE):
	wget -O $@ $(WXURL)

$(HARUFILE):
	wget -O $@ $(HARUURL)

$(ZLIBFILE):
	wget -O $@ $(ZLIBURL)

$(PNGFILE):
	wget -O $@ $(PNGURL)

$(CURLTARGET): $(CURLFILE) $(ZLIBTARGET)
	rm -rf $(CURL)
	tar -xf $(CURLFILE)
	(cd $(CURL); $(CURLCONFIG) )
	rm $(CURL)/scripts/zsh.pl
	cp /dev/null $(CURL)/scripts/zsh.pl
	$(MAKE) -C $(CURL)
	rm -rf $(CURL)/scripts
	ln -s include $(CURL)/scripts
	$(MAKE) -C $(CURL) install
	cp $(CURL)/lib/.libs/libcurl-4.dll $(ROOTFS)/lib/

$(QRENCODETARGET): $(QRENCODEFILE)
	rm -rf $(QRENCODE)
	tar -xf $(QRENCODEFILE)
	(cd $(QRENCODE); $(QRENCODECONFIG) )
	$(MAKE) -C $(QRENCODE)
	$(MAKE) -C $(QRENCODE) install

$(LUATARGET): $(LUAFILE)
	rm -rf $(LUA)
	tar -xf $(LUAFILE)
	$(MAKE) -C $(LUA)/src $(LUACONFIG) lua.exe
	cp $(LUA)/src/lua.h $(ROOTFS)/include
	cp $(LUA)/src/luaconf.h $(ROOTFS)/include
	cp $(LUA)/src/lualib.h $(ROOTFS)/include
	cp $(LUA)/src/lauxlib.h $(ROOTFS)/include
	cp $(LUA)/src/lua.hpp $(ROOTFS)/include
	cp $(LUA)/src/lua52.dll $(ROOTFS)/lib

$(WXTARGET): $(WXFILE) $(PNGTARGET)
	rm -rf $(WX)
	tar -xf $(WXFILE)
	mkdir $(WX)/build_win32
	(cd $(WX)/build_win32; $(WXCONFIG) )
	$(MAKE) -C $(WX)/build_win32
	$(MAKE) -C $(WX)/build_win32 install

$(ZLIBTARGET): $(ZLIBFILE)
	rm -rf $(ZLIB)
	tar -xf $(ZLIBFILE)
	(cd $(ZLIB); $(ZLIBCONFIG) )
	$(MAKE) -C $(ZLIB) install

$(HARUTARGET): $(HARUFILE) $(PNGTARGET)
	rm -rf $(HARUDIR)
	unzip $(HARUFILE)
	(cd $(HARUDIR); $(HARUCONFIG) )
	$(MAKE) -C $(HARUDIR)
	$(MAKE) -C $(HARUDIR) install

$(PNGTARGET): $(PNGFILE) $(ZLIBTARGET)
	rm -rf $(PNG)
	tar -xf $(PNGFILE)
	(cd $(PNG); $(PNGCONFIG) )
	$(MAKE) -C $(PNG)
	$(MAKE) -C $(PNG) install

clean:
	rm -rf $(CURL)
	rm -rf $(QRENCODE)
	rm -rf $(LUA)
	rm -rf $(WX)
	rm -rf $(HARUDIR)
	rm -rf $(ZLIB)
	rm -rf $(PNG)
	rm -rf $(ROOTFS)
	mkdir -p $(ROOTFS)
	mkdir -p $(ROOTFS)/include
	mkdir -p $(ROOTFS)/lib
	
