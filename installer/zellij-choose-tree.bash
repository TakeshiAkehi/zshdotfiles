#!/bin/bash
# zellij-choose-tree (https://github.com/laperlej/zellij-choose-tree) をサイドバー用パッチ付きでビルドして配置する
#   - Esc / 選択時に exit_layout で指定したレイアウトへ戻す (hide せず閉じる)
#   - zellij 0.45 以降で他セッションも一覧に出るよう定期的にセッション一覧を取得する
# パッチ or コミットが変わったときだけ再ビルドする

CDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
REPO_URL="https://github.com/laperlej/zellij-choose-tree"
REPO_COMMIT="8dd9d7de4ffdcbcc15ca32ebf221c6d4b75371ab"
PATCH="${CDIR}/zellij-choose-tree/sidebar.patch"
PLUGIN_DIR="${HOME}/.config/zellij/plugins"
WASM="${PLUGIN_DIR}/zellij-choose-tree.wasm"
STAMP="${WASM}.stamp"
TARGET="wasm32-wasip1"

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

stamp="${REPO_COMMIT} $(sha256sum "${PATCH}" | cut -d' ' -f1)"
if [ -f "${WASM}" ] && [ "$(cat "${STAMP}" 2>/dev/null)" = "${stamp}" ]; then
    echo "skipped : zellij-choose-tree has already installed"
    exit 0
fi

if ! type "cargo" > /dev/null 2>&1; then
    echo "error : cargo is required to build zellij-choose-tree (run installer/tui.bash first)"
    exit 1
fi
if type "rustup" > /dev/null 2>&1; then
    rustup target add ${TARGET}
else
    echo "warning : rustup not found, assuming ${TARGET} target is already available"
fi

echo "installing zellij-choose-tree"
BUILD_DIR=$(mktemp -d)
trap 'rm -rf "${BUILD_DIR}"' EXIT
git clone --quiet "${REPO_URL}" "${BUILD_DIR}/src" \
    && git -C "${BUILD_DIR}/src" checkout --quiet "${REPO_COMMIT}" \
    && git -C "${BUILD_DIR}/src" apply "${PATCH}" \
    && (cd "${BUILD_DIR}/src" && cargo build --release --target ${TARGET}) \
    || { echo "error : failed to build zellij-choose-tree"; exit 1; }

mkdir -p "${PLUGIN_DIR}"
cp "${BUILD_DIR}/src/target/${TARGET}/release/zellij-choose-tree.wasm" "${WASM}"
echo "${stamp}" > "${STAMP}"
echo "installed : ${WASM}"
