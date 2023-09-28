#!/usr/bin/env bash

set -eu

readonly SSH_PATH=~/.ssh/id_ed25519
readonly SSH_PUBKEY=~/.ssh/id_ed25519.pub
readonly BREW_PREFIX=$(brew --prefix)

cat <<EOF
Welcome to your friendly SSH and GnuPG key generation assistant!

[*] Please enter your full name and your Personio email address in the next steps.

EOF

read -p "Full Name (Firstname Lastname): " name
read -p "E-Mail (firstname.lastname@personio.de): " email
echo ''

if [ ! -e "$SSH_PATH" ]; then
    ssh-keygen -t ed25519 -f "$SSH_PATH" -C "$email"
else
    echo "[*] It looks like there is already an SSH key at $SSH_PATH. I will not generate a new key."
fi

tr -d '\n' < "$SSH_PUBKEY" | pbcopy
echo '[*] I have copied your SSH public key into the clipboard. Please add it to your GitLab account at https://gitlab.personio-internal.de/-/profile/keys'
read -p 'Press Enter to continue...'

echo '[*] Adding your SSH key to the SSH Agent.'
ssh-add "$SSH_PATH"

cat <<EOF

Next up is generating your GnuPG key for signing Git commits.

EOF

if ! command -v gpg &> /dev/null ; then
  echo "[*] Installing GnuPG with Homebrew."
  brew install --quiet gnupg pinentry-mac
  brew link --quiet --overwrite gpg
fi

if [ ! -d ~/.gnupg ]; then
  mkdir -p ~/.gnupg
  chmod 700 ~/.gnupg
fi

echo "[*] Setting config for gpg and pinentry-mac."
grep -q '^pinentry-program' ~/.gnupg/gpg-agent.conf && sed -i '.bak' "s|^pinentry-program.*|pinentry-program ${BREW_PREFIX}/bin/pinentry-mac|" ~/.gnupg/gpg-agent.conf || echo "pinentry-program ${BREW_PREFIX}/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
grep -q '^use-agent' ~/.gnupg/gpg.conf || echo 'use-agent' >> ~/.gnupg/gpg.conf

echo "[*] Configuring your login shell ($SHELL)."
if [ "${SHELL##*/}" = "bash" ]; then
  grep -q '^export GPG_TTY' ~/.bashrc && sed -i '.bak' 's|^export GPG_TTY.*|export GPG_TTY=`tty`|' ~/.bashrc || echo 'export GPG_TTY=`tty`' >> ~/.bashrc
elif [ "${SHELL##*/}" = "zsh" ]; then
  grep -q '^export GPG_TTY' ~/.zshrc && sed -i '.bak' 's|^export GPG_TTY.*|export GPG_TTY=`tty`|' ~/.zshrc || echo 'export GPG_TTY=`tty`' >> ~/.zshrc
else
  echo "[!] Looks like you're using an unsupported shell. Please add the necessary configuration for the \$GPG_TTY environment variable yourself."
fi

if ! gpg -k "$email" &> /dev/null ; then
    echo "[*] Generating your OpenPGP key."
    cat >params <<EOF
        %echo Generating a basic OpenPGP key
        Key-Type: RSA
        Key-Usage: sign
        Key-Length: 4096
        Name-Real: $name
        Name-Email: $email
        %ask-passphrase
        %commit
        %echo done
EOF
    gpg --quiet --gen-key --batch params || {
      echo "[!] Generating your OpenPGP key failed. The following config was used for generating the OpenPGP key:"
      cat params
      cat ~/.gnupg/gpg-agent.conf
      cat ~/.gnupg/gpg.conf
      exit 1
    }
else
    echo "[*] It looks like there is already a GnuPG key for $email. I will not generate a new key."
fi

keyid=$(gpg --list-secret-keys --with-colons "$email" | grep '^sec' | cut -d ':' -f 5)

echo "[*] Configuring Git to sign commits with GnuPG key $keyid."
git config --global gpg.program "$(which gpg)"
git config --global user.signingkey "$keyid"
git config --global commit.gpgsign true

gpg --armor --export "$keyid" | pbcopy

echo ''
echo "[*] I have copied your GnuPG public key into the clipboard. Please add it to your GitLab account at https://gitlab.personio-internal.de/-/profile/gpg_keys"
read -p 'Press Enter to continue...'

cat <<EOF

Congratulations, we're done!

Also please restart your shell to load the updated rc file before signing your first commit.
EOF
