say_hello:
	@echo "      _       _         __ _ _"
	@echo "   __| | ___ | |_      / _(_) | ___  ___"
	@echo "  / _\`|/ _ \| __|____| |_| | |/ _ \/ __|"
	@echo " | (_| | (_) | ||_____|  _| | |  __/\__ \\"
	@echo "  \__,_|\___/ \__|    |_| |_|_|\___||___/"
	@echo ""
	@echo "Let's make debian/redhat/macos to start bootstrap process"

macos: say_hello
	@chmod u+x ./bootstrap_scripts/bootstrap_macos.sh
	@./bootstrap_scripts/bootstrap_macos.sh

