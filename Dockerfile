# 使用官方的 Python 3.9 slim 版本作为基础镜像
FROM python:3.9-slim

# 设置工作目录为 /ai_api
WORKDIR /ai_api

# 将当前目录的所有文件复制到容器的 /ai_api 目录下
COPY . /ai_api

# 安装项目所需的 Python 依赖
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir fastapi gunicorn uvicorn requests pydantic

# 创建日志目录
RUN mkdir -p /ai_api/logs

# 设置环境变量，日志文件的存放位置
ENV LOG_DIR=/ai_api/logs

# 使用 Gunicorn 运行 FastAPI 应用，加载 gunicorn.conf.py 配置文件
CMD ["gunicorn", "app:app", "-c", "gunicorn.conf.py"]
