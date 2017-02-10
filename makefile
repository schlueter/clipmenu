.PHONY: install _setup-init _install-config env

CONFIG_FILE=/etc/default/clipmenud

USE_SYSTEMD=$(shell if systemctl --version >/dev/null 2>/dev/null; then echo yes; else echo no; fi)

install: _setup-init
	install clipmenu /usr/bin
	install clipmenud /usr/bin

ifeq ($(USE_SYSTEMD),yes)
_setup-init: _install-config _systemd-install
else
_setup-init:
	@echo Could not detect init system.
endif

_install-config:
	@if [ -f $(CONFIG_FILE) ]; then \
		while [ -z "$$CONFIRM" ]; do \
			read -r -p "Clipmenu configuration exists at $(CONFIG_FILE), would you like to overwrite? [y/N]" CONFIRM;\
		done && \
		( \
			case $$CONFIRM in \
				[yY]*) make _config ;; \
				*) echo 'Not writing $(CONFIG_FILE)'; \
			esac ); \
	else \
		make config; \
	fi

_systemd-install:
	install -m666 clipmenu.service /usr/lib/systemd/user
	install -m666 clipmenu.timer /usr/lib/systemd/user
	@echo 'Run `systemctl --user daemon-reload && systemctl --user restart clipmenu` to activate for current user.'

_config:
	@echo 'Writing $(CONFIG_FILE)';
	install -d /etc/default
	echo 'DISPLAY=$$DISPLAY' > $(CONFIG_FILE);
	@if [ -z "$$DEBUG" ]; then echo 'DEBUG=1' >> $(CONFIG_FILE); fi

env:
	@echo USE_SYSTEMD=$(USE_SYSTEMD)
