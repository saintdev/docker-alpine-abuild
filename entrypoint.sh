#!/bin/sh

set -e

keygen() {
  local r
  if [ -n "$PACKAGER" ]; then
    echo "PACKAGER=\"$PACKAGER\"" | sudo tee -a /etc/abuild.conf
    echo "MAINTAINER=\"\$PACKAGER\"" | sudo tee -a /etc/abuild.conf
    abuild-keygen -a -n
    sudo cp "$HOME"/.abuild/*.pub /etc/apk/keys/
  fi
}

checksum() {
  exec abuild checksum
}

build() {
  local repo; local package
  local url="git://git.alpinelinux.org/aports"
  local branch="master"

  shift
  mkdir -p "$REPODEST" "$PKGSRC"

  if [ $# -ge 2 -a $# -lt 5 ]; then
    repo=$1
    package=$2
    [ $# -ge 3 ] && url=$3
    [ $# -eq 4 ] && branch=$4
    git clone --depth 1 --single-branch --branch "$branch" "$url" "$HOME/aports"
    cp -r "$HOME/aports/$repo/$package/"* "$PKGSRC"/
  elif [ ! $# -eq 0 ]; then
    echo "build: unknown paramaters: $@"
    return 0
  fi

  abuild-apk update

  [ "$RSA_PRIVATE_KEY" ] && {
    echo -e "$RSA_PRIVATE_KEY" > "$HOME/.abuild/$RSA_PRIVATE_KEY_NAME"
    export PACKAGER_PRIVKEY="$HOME/.abuild/$RSA_PRIVATE_KEY_NAME"
  }

  exec abuild -r
}

help() {
  if [ -z "$@" ]; then
    echo "syntax: command [parameters]"
    echo ""
    echo "Available commands:"
    echo "  keygen"
    echo "  checksum"
    echo "  build [repo package] [git_url [branch]]"
    echo "  help"
  fi
  return 1
}

main() {
  case "$1" in
    build ) build "$@" ;;
    keygen ) keygen ;;
    checksum ) checksum ;;
    /*bin/* ) exec $@ ;;
    * ) help ;;
  esac

  return $?
}

main "$@"
