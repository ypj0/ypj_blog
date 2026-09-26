#!/usr/bin/env bash
# Activate the Ruby installed in the workspace rather than relying on a system Ruby.

if [[ -n "${BASH_VERSION:-}" ]]; then
  _script_path="${BASH_SOURCE[0]}"
else
  # zsh exposes the path of a sourced file through this prompt expansion.
  _script_path="${(%):-%N}"
fi

_blog_root="$(cd "$(dirname "$_script_path")/.." && pwd)"
export RBENV_ROOT="${_blog_root%/*}/.rbenv"
export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"

eval "$(rbenv init -)"
rbenv shell 3.3.6

echo "Using $(ruby --version)"
echo "Using $(bundle --version)"
