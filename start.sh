#!/bin/bash

# 默认设置
IMAGE_NAME="ai_api"
CONTAINER_NAME="ai_api"
LOG_DIR="./logs"
LOG_FILE="${LOG_DIR}/gunicorn.log"
ERROR_LOG_FILE="${LOG_DIR}/gunicorn_error.log"
MAX_LOG_SIZE=1048576  # 1GB in KB

# 检查日志大小，如果超过1GB，则清理日志
check_log_size() {
  if [ -f "$LOG_FILE" ] && [ $(du -k "$LOG_FILE" | cut -f1) -ge $MAX_LOG_SIZE ]; then
    echo "日志大小超过1GB，正在清理日志文件..."
    > "$LOG_FILE"
  fi

  if [ -f "$ERROR_LOG_FILE" ] && [ $(du -k "$ERROR_LOG_FILE" | cut -f1) -ge $MAX_LOG_SIZE ]; then
    echo "错误日志大小超过1GB，正在清理日志文件..."
    > "$ERROR_LOG_FILE"
  fi
}

# 选项1: 安装并运行容器
install_container() {
  read -p "请输入要使用的端口号 (默认 8000): " PORT

  if [ -z "$PORT" ]; then
    PORT=8000
  fi

  echo "安装并运行Docker容器，端口号: $PORT..."
  
  docker build -t $IMAGE_NAME .
  
  docker run -d --name $CONTAINER_NAME -p $PORT:8000 -v $(pwd):/ai_api $IMAGE_NAME
}

# 选项2: 停止并卸载容器与镜像
stop_and_remove() {
  echo "停止并删除容器和镜像..."
  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
  docker rmi $IMAGE_NAME
}

# 选项3: 修改端口并重启容器
modify_and_restart() {
  read -p "请输入新的端口号 (当前为8000): " NEW_PORT

  if [ -z "$NEW_PORT" ]; then
    NEW_PORT=8000
  fi

  echo "修改端口为: $NEW_PORT，并重启容器..."

  docker stop $CONTAINER_NAME
  docker rm $CONTAINER_NAME
  docker run -d --name $CONTAINER_NAME -p $NEW_PORT:8000 -v $(pwd)/ai_api:/ai_api $IMAGE_NAME gunicorn app:app -c gunicorn.conf.py --bind 0.0.0.0:$NEW_PORT
}

# 选项4: 查看日志
view_logs() {
  echo "查看日志..."
  check_log_size
  tail -f $LOG_FILE
}

# 主菜单
echo "请选择一个选项:"
echo "1) 安装并运行Docker容器"
echo "2) 停止并卸载容器与镜像"
echo "3) 修改端口并重启容器"
echo "4) 查看日志"

read -p "请输入选项 (1-4): " OPTION

case $OPTION in
  1)
    install_container
    ;;
  2)
    stop_and_remove
    ;;
  3)
    modify_and_restart
    ;;
  4)
    view_logs
    ;;
  *)
    echo "无效的选项，请选择 1-4."
    ;;
esac
