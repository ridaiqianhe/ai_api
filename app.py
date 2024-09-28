from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import requests

# 创建 FastAPI 应用
app = FastAPI()

# 定义请求体的数据模型
class GPTRequest(BaseModel):
    url: str
    token: str
    user_content: str
    system_content: str
    temperature: float = 0.6

# 定义与 GPT API 通信的函数
def gpt_completion(url, token, user_content, system_content, temperature=0.6):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    data = {
        "model": "gpt-4o-mini",
        "messages": [
            {
                "role": "system",
                "content": system_content
            },
            {
                "role": "user",
                "content": user_content
            }
        ],
        "temperature": temperature
    }

    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 200:
        return response.text
    else:
        raise HTTPException(status_code=response.status_code, detail="Request failed")

# 定义一个 POST 请求的路由
@app.post("/chat")
def chat_gpt(request: GPTRequest):
    try:
        # 调用 gpt_completion 函数
        result = gpt_completion(
            request.url, 
            request.token, 
            request.user_content, 
            request.system_content, 
            request.temperature
        )
        return result
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))