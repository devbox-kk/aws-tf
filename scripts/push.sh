#!/bin/bash

# Docker イメージをECRにプッシュするスクリプト
# 使用方法: ./push.sh [dev|prod] [image-tag]
# または、build.sh実行後に環境変数を使用して: ./push.sh

set -e

# 共通関数をインポート
source "$(dirname "$0")/lib/common.sh"

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}

# 設定値
AWS_REGION="ap-northeast-1"
REPOSITORY_NAME="helloworld-${ENVIRONMENT}"

# build.shから環境変数が設定されている場合は、それを使用
if [[ -n "$BUILT_IMAGE_NAME" ]]; then
    FULL_IMAGE_NAME="$BUILT_IMAGE_NAME"
    REPOSITORY_NAME="$BUILT_REPOSITORY_NAME"
    IMAGE_TAG="$BUILT_IMAGE_TAG"
    ECR_REGISTRY="$BUILT_ECR_REGISTRY"
    AWS_REGION="$BUILT_AWS_REGION"
    
    log_info "Using environment variables from build process"
else
    # 引数チェック
    if ! validate_environment "$ENVIRONMENT"; then
        exit 1
    fi
    
    # AWS CLI の設定確認
    if ! check_aws_config; then
        exit 1
    fi
    
    # AWS Account ID を取得
    AWS_ACCOUNT_ID=$(get_aws_account_id)
    ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    FULL_IMAGE_NAME="${ECR_REGISTRY}/${REPOSITORY_NAME}:${IMAGE_TAG}"
    
    show_config "$AWS_ACCOUNT_ID" "$ECR_REGISTRY" "$REPOSITORY_NAME" "$FULL_IMAGE_NAME"
fi

log_info "Starting push process for $ENVIRONMENT environment"

# イメージが存在するかチェック
if ! docker image inspect "$FULL_IMAGE_NAME" >/dev/null 2>&1; then
    log_error "Image $FULL_IMAGE_NAME not found. Please build the image first."
    exit 1
fi

# ECR ログイン
if ! login_to_ecr "$AWS_REGION" "$ECR_REGISTRY"; then
    log_error "Failed to login to ECR"
    exit 1
fi

# ECR にプッシュ
log_info "Pushing image to ECR..."
docker push "$FULL_IMAGE_NAME"

log_info "Successfully pushed image: $FULL_IMAGE_NAME"

# ローカルの一時イメージを削除
cleanup_local_images "$REPOSITORY_NAME" "$IMAGE_TAG" "$FULL_IMAGE_NAME"

log_info "Push completed successfully!"
