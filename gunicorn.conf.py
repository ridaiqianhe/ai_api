import os
from logging.handlers import RotatingFileHandler

# 日志目录
LOG_DIR = "/ai_api/logs"
if not os.path.exists(LOG_DIR):
    os.makedirs(LOG_DIR)

# 基本配置
loglevel = 'info'
workers = os.cpu_count() * 2 + 1  # 根据 CPU 核心数自动计算 workers 数量
worker_class = 'uvicorn.workers.UvicornWorker'  # 使用 Uvicorn Worker 来处理 FastAPI 应用
bind = '0.0.0.0:8000'

# 日志文件路径
accesslog = f"{LOG_DIR}/gunicorn_access.log"
errorlog = f"{LOG_DIR}/gunicorn_error.log"

# 自定义的日志配置，设置日志轮转
def post_fork(server, worker):
    log_file = f"{LOG_DIR}/gunicorn.log"
    
    handler = RotatingFileHandler(log_file, maxBytes=1 * 1024 * 1024 * 1024, backupCount=3)
    handler.setLevel("INFO")
    
    server.log.access_log.addHandler(handler)
    server.log.error_log.addHandler(handler)
