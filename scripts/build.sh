#!/bin/bash

# Docker イメージをビルドするスクリプト
# 使用方法: ./build.sh [dev|prod] [image-tag]

set -e

# 共通関数をインポート
source "$(dirname "$0")/lib/common.sh"

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}

# 設定値
AWS_REGION="ap-northeast-1"
REPOSITORY_NAME="helloworld-${ENVIRONMENT}"
DOCKERFILE_PATH="../docker/helloworld"

# 引数チェック
if ! validate_environment "$ENVIRONMENT"; then
    exit 1
fi

log_info "Starting build process for $ENVIRONMENT environment"

# AWS CLI の設定確認
if ! check_aws_config; then
    exit 1
fi

# AWS Account ID を取得
AWS_ACCOUNT_ID=$(get_aws_account_id)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_NAME="${ECR_REGISTRY}/${REPOSITORY_NAME}:${IMAGE_TAG}"

show_config "$AWS_ACCOUNT_ID" "$ECR_REGISTRY" "$REPOSITORY_NAME" "$FULL_IMAGE_NAME"

# Docker イメージをビルド
log_info "Building Docker image..."
DOCKER_BUILDKIT=0 docker build -t "$REPOSITORY_NAME:$IMAGE_TAG" "$DOCKERFILE_PATH"

# イメージにタグ付け
log_info "Tagging image..."
docker tag "$REPOSITORY_NAME:$IMAGE_TAG" "$FULL_IMAGE_NAME"

log_info "Build completed successfully!"
log_info "Local image: $REPOSITORY_NAME:$IMAGE_TAG"
log_info "Tagged image: $FULL_IMAGE_NAME"

# 環境変数をエクスポート（他のスクリプトから使用される場合）
export BUILT_IMAGE_NAME="$FULL_IMAGE_NAME"
export BUILT_REPOSITORY_NAME="$REPOSITORY_NAME"
export BUILT_IMAGE_TAG="$IMAGE_TAG"
export BUILT_ECR_REGISTRY="$ECR_REGISTRY"
export BUILT_AWS_REGION="$AWS_REGION"
