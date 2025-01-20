#!/bin/bash

# Biến cấu hình
REMOTE_USER="ubuntu"                  # Tên người dùng SSH
REMOTE_HOST="103.172.239.184"         # Địa chỉ IP hoặc tên miền của server
REMOTE_PORT=3000                      # Port SSH, mặc định là 22
LOCAL_FILE="docker-compose.yaml"      # Đường dẫn file docker-compose.yaml trên local
ENV_FILE=".env"                       # Đường dẫn file env trên local
ENV_PATH="/home/ubuntu/.env"                       
REMOTE_PATH="/home/ubuntu/docker-compose.yaml"  # Đường dẫn lưu file trên server

# Upload file qua SCP
echo "Uploading $LOCAL_FILE to $REMOTE_HOST:$REMOTE_PATH..."
scp -P $REMOTE_PORT $LOCAL_FILE ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}
if [ $? -ne 0 ]; then
  echo "File upload failed. Exiting."
  exit 1
fi
echo "File $LOCAL_FILE upload successful."

echo "Uploading $ENV_FILE to $REMOTE_HOST:$ENV_PATH..."
scp -P $REMOTE_PORT $ENV_FILE ${REMOTE_USER}@${REMOTE_HOST}:${ENV_PATH}
if [ $? -ne 0 ]; then
  echo "File upload failed. Exiting."
  exit 1
fi
echo "File $ENV_FILE upload successful."

# Chạy lệnh docker-compose trên server
echo "Running docker-compose up on $REMOTE_HOST..."
ssh -p $REMOTE_PORT ${REMOTE_USER}@${REMOTE_HOST} << EOF
  cd $(dirname $REMOTE_PATH) && docker-compose up
EOF

if [ $? -eq 0 ]; then
  echo "Docker Compose started successfully."
else
  echo "Failed to run Docker Compose."
fi
