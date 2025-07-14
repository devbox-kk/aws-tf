#!/bin/bash

# Docker イメージをビルドしてECRにプッシュするスクリプト
# 使用方法: ./build-and-push.sh [dev|prod] [image-tag]

set -e

ENVIRONMENT=${1:-dev}
IMAGE_TAG=${2:-latest}

# 設定値
AWS_REGION="ap-northeast-1"
REPOSITORY_NAME="helloworld-${ENVIRONMENT}"
DOCKERFILE_PATH="../docker/helloworld"

# 色付きログ用関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

log_warn() {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

# 引数チェック
if [[ ! "$ENVIRONMENT" =~ ^(dev|prod)$ ]]; then
    log_error "Invalid environment. Please specify 'dev' or 'prod'"
    exit 1
fi

log_info "Starting build and push process for $ENVIRONMENT environment"

# AWS CLI の設定確認
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    log_error "AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

# AWS Account ID を取得
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FULL_IMAGE_NAME="${ECR_REGISTRY}/${REPOSITORY_NAME}:${IMAGE_TAG}"

log_info "AWS Account ID: $AWS_ACCOUNT_ID"
log_info "ECR Registry: $ECR_REGISTRY"
log_info "Repository Name: $REPOSITORY_NAME"
log_info "Full Image Name: $FULL_IMAGE_NAME"

# ECR ログイン
log_info "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Docker イメージをビルド
log_info "Building Docker image..."
DOCKER_BUILDKIT=0 docker build -t $REPOSITORY_NAME:$IMAGE_TAG $DOCKERFILE_PATH

# イメージにタグ付け
log_info "Tagging image..."
docker tag $REPOSITORY_NAME:$IMAGE_TAG $FULL_IMAGE_NAME

# ECR にプッシュ
log_info "Pushing image to ECR..."
docker push $FULL_IMAGE_NAME

log_info "Successfully pushed image: $FULL_IMAGE_NAME"

# ローカルの一時イメージを削除
log_info "Cleaning up local images..."
docker rmi $REPOSITORY_NAME:$IMAGE_TAG || true
docker rmi $FULL_IMAGE_NAME || true

log_info "Build and push completed successfully!"
