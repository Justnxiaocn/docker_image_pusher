#!/bin/bash
echo "🧪 Testing image sync configuration"

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试的镜像列表
TEST_IMAGES=(
  "crpi-bu81i2sck83t8ml8.cn-hangzhou.personal.cr.aliyuncs.com/k8s_official/pause:3.9"
  "crpi-bu81i2sck83t8ml8.cn-hangzhou.personal.cr.aliyuncs.com/k8s_ecosystem/nginx-ingress:1.8.0"
  "crpi-bu81i2sck83t8ml8.cn-hangzhou.personal.cr.aliyuncs.com/k8s_app_images/backend:1.0.0"
)

# 检查是否安装了crictl
if ! command -v crictl &> /dev/null; then
    echo -e "${YELLOW}⚠️ crictl not found, trying docker...${NC}"
    
    # 如果没有crictl，尝试使用docker
    for image in "${TEST_IMAGES[@]}"; do
        echo -e "Testing pull for: ${YELLOW}$image${NC}"
        if sudo docker pull "$image"; then
            echo -e "${GREEN}✅ Success: $image${NC}"
            # 清理拉取的镜像
            sudo docker rmi "$image" 2>/dev/null || true
        else
            echo -e "${RED}❌ Failed: $image${NC}"
            exit 1
        fi
    done
else
    # 使用crictl进行测试
    for image in "${TEST_IMAGES[@]}"; do
        echo -e "Testing pull for: ${YELLOW}$image${NC}"
        if sudo crictl pull "$image"; then
            echo -e "${GREEN}✅ Success: $image${NC}"
        else
            echo -e "${RED}❌ Failed: $image${NC}"
            exit 1
        fi
    done
fi

# 测试Kubernetes部署文件语法
echo -e "\n🧪 Testing Kubernetes deployment files..."
if command -v kubectl &> /dev/null; then
    for file in k8s/*/*.yaml; do
        if [ -f "$file" ]; then
            echo -e "Validating: ${YELLOW}$file${NC}"
            if kubectl apply --dry-run=client -f "$file" &> /dev/null; then
                echo -e "${GREEN}✅ Valid: $file${NC}"
            else
                echo -e "${RED}❌ Invalid: $file${NC}"
                exit 1
            fi
        fi
    done
else
    echo -e "${YELLOW}⚠️ kubectl not found, skipping deployment validation${NC}"
fi

echo -e "\n🎉 All tests passed! Your configuration is working correctly."
