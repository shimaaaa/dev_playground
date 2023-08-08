from fastapi import FastAPI

app = FastAPI()


@app.get("/ping")
def ping() -> str:
    return "pong"


@app.get("/api")
def read_root() -> dict:
    return {"Hello": "World"}
