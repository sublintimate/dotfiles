#!/bin/sh

# -e: exit on error
# -u: exit on unset variables
set -eu

# chezmoiがインストールされているか確認
if ! command -v chezmoi > /dev/null 2>&1; then
    # OSの種類を確認
    if [ "$(uname)" = "Darwin" ]; then
        # MacOS
        echo "Installing chezmoi via Homebrew" >&2

        # Homebrewがインストールされているか確認
        if ! command -v brew > /dev/null 2>&1; then
            # Homebrewのインストール
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi

        # chezmoiのインストール
        brew install chezmoi
    elif [ -e /etc/debian_version ] || [ -e /etc/debian_release ]; then
        # Ubuntu or Debian
        echo "Installing chezmoi via Snappy" >&2

        # Snappyがインストールされているか確認
        if ! command -v snap > /dev/null 2>&1; then
            # Snappyのインストール
            sudo apt install snapd
        fi

        # chezmoiのインストール
        sudo snap install chezmoi --classic
    else
        echo "This platform is not supported" >&2
    fi
fi

echo "Running 'chezmoi init --apply $*'" >&2
chezmoi init --apply "$@"
