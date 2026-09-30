import os 
from flask import Flask, jsonify, request

app = Flask(__name__)
tasks = [] 

@app.get("/health")
def health():
	return jsonify(status="ok")

@app.get("/version")
def version():
	return jsonify(version=os.getenv("APP_VERSION", "unknown"))

@app.get("/tasks")
def list_tasks():
	return jsonify(tasks)

@app.post("/tasks")
def create_task():
	data = request.get_json(silent=True) or {}
	if not data.get("title"):
		return jsonify(error="title is required"), 400
	task = {"id": len(tasks) + 1, "title": data["title"], "done": bool(data.get("done", False))}
	tasks.append(task)
	return jsonify(task), 201