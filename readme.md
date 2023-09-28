NOTE:

**BEFORE Installation**
- BEFORE installing Yabai, we should disable System Integrity Protection on MacOS. Just following the instruction below:
Typing command: `csrutil disable` in the booting mode's terminal
Double-check: `csrutil status` in the normal terminal
https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection

- BEFORE Do COPY FILES step. We should make sure your terminal is working with GNU syntax. IF NOT please follow the instruction below to install them:
https://gist.github.com/skyzyx/3438280b18e4f7c490db8a2a2ca0b9da
	1. Install most of the GNU flavored tools with:
	```sh
	brew install autoconf bash binutils coreutils diffutils ed findutils flex gawk \
    gnu-indent gnu-sed gnu-tar gnu-which gpatch grep gzip less m4 make nano \
    screen watch wdiff wget
	```
	2. Append the following to your ~/.zshrc file.
	```sh
	if type brew &>/dev/null; then
	  HOMEBREW_PREFIX=$(brew --prefix)
	  # gnubin; gnuman
	  for d in ${HOMEBREW_PREFIX}/opt/*/libexec/gnubin; do export PATH=$d:$PATH; done
	  # I actually like that man grep gives the BSD grep man page
	  #for d in ${HOMEBREW_PREFIX}/opt/*/libexec/gnuman; do export MANPATH=$d:$MANPATH; done
	fi
	```

**AFTER Installation**
- To set a Version of Python to Global Default:
	```shell
	pyenv global 3.9.10
	pyenv versions
	```
