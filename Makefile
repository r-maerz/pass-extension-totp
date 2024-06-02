PREFIX ?= /usr
DESTDIR ?=
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man

all:
	@echo "pass-extension-totp is a shell script, so there is nothing to do. Try \"sudo make install\" instead."

install:
	@install -v -d "$(DESTDIR)$(MANDIR)/man1" && install -m 0644 -v man/totp.1 "$(DESTDIR)$(MANDIR)/man1/pass-extension-totp.1"
	@install -m 0755 -v src/pass-extension-totp.bash "$(DESTDIR)$(LIBDIR)/password-store/extensions/totp.bash"

uninstall:
	@rm -vrf \
		"$(DESTDIR)$(LIBDIR)/password-store/extensions/totp.bash" \
		"$(DESTDIR)$(MANDIR)/man1/pass-extension-totp.1"

.PHONY: install uninstall 
