#!/bin/bash
set -e

SOURCE_IMAGE=$1
TARGET_IMAGE=$2

echo "🚀 Syncing $SOURCE_IMAGE to $TARGET_IMAGE"

# 拉取源镜像
echo "📥 Pulling source image..."
docker pull $SOURCE_IMAGE

# 标记为目标镜像
echo "🏷️ Tagging image..."
docker tag $SOURCE_IMAGE $TARGET_IMAGE

# 推送到阿里云
echo "📤 Pushing to Aliyun..."
docker push $TARGET_IMAGE

# 清理本地镜像
echo "🧹 Cleaning up..."
docker rmi $SOURCE_IMAGE $TARGET_IMAGE 2>/dev/null || true

echo "✅ Successfully synced $SOURCE_IMAGE to $TARGET_IMAGE"
echo ""
