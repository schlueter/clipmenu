.PHONY: install debug config debug-install

CONFIG_FILE=/etc/default/clipmenud

install:
	install clipmenu /usr/bin
	install clipmenud /usr/bin
	install clipmenu.service /usr/lib/systemd/user
	@if [ -f $(CONFIG_FILE) ]; then \
		while [ -z "$$CONFIRM" ]; do \
			read -r -p "Clipmenu configuration exists at $(CONFIG_FILE), would you like to override? [y/N]" CONFIRM;\
		done && \
		( \
			case $$CONFIRM in \
				[yY]*) make config ;; \
				*) echo 'Not writing $(CONFIG_FILE)'; \
			esac ); \
	else \
		make config; \
	fi

config:
	@echo 'Writing $(CONFIG_FILE)';
	install -d /etc/default
	echo 'DISPLAY=:0' > $(CONFIG_FILE);

debug:
	echo 'DEBUG=1' >> $(CONFIG_FILE)

debug-install: |install debug
