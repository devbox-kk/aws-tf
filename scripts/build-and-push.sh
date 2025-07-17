#!/bin/bash

# Docker イメージをビルドしてECRにプッシュするスクリプト
# 使用方法: ./build-and-push.sh [dev|prod] [image-tag]

set -e

# 共通関数をインポート
source "$(dirname "$0")/lib/common.sh"

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}

# 引数チェック
if ! validate_environment "$ENVIRONMENT"; then
    exit 1
fi

log_info "Starting build and push process for $ENVIRONMENT environment"

# ビルド処理を実行
log_info "=== BUILD PHASE ==="
if ! bash "$(dirname "$0")/build.sh" "$ENVIRONMENT" "$IMAGE_TAG"; then
    log_error "Build phase failed"
    exit 1
fi

log_info "=== PUSH PHASE ==="
# プッシュ処理を実行（環境変数を使用）
export CLEANUP_LOCAL_IMAGES=true
if ! bash "$(dirname "$0")/push.sh"; then
    log_error "Push phase failed"
    exit 1
fi

log_info "Build and push completed successfully!"
