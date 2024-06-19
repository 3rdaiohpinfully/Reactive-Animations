from flask import Flask, request, jsonify, send_from_directory
import os
import uuid
import subprocess

app = Flask(__name__)
UPLOAD_FOLDER = 'uploads'
RESULT_FOLDER = 'results'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULT_FOLDER, exist_ok=True)

jobs = {}

@app.route('/api/upload', methods=['POST'])
def upload_file():
    if 'audio' not in request.files:
        return jsonify({"error": "No audio file provided"}), 400

    audio = request.files['audio']
    job_id = str(uuid.uuid4())

    audio_path = os.path.join(UPLOAD_FOLDER, f"{job_id}_audio.mp3")
    audio.save(audio_path)

    jobs[job_id] = {"status": "processing", "audio_path": audio_path}

    # Call the processing function asynchronously
    subprocess.Popen(["python3", "process_animation.py", job_id])

    return jsonify({"jobId": job_id}), 200

@app.route('/api/status/<job_id>', methods=['GET'])
def check_status(job_id):
    job = jobs.get(job_id)
    if job:
        return jsonify({"status": job["status"], "animationUrl": job.get("animation_url")})
    return jsonify({"error": "Job not found"}), 404

@app.route('/results/<path:filename>', methods=['GET'])
def download_file(filename):
    return send_from_directory(RESULT_FOLDER, filename)

def process_job(job_id):
    job = jobs[job_id]
    audio_path = job["audio_path"]

    # Generate the animation using the relevant repository scripts
    animation_path = os.path.join(RESULT_FOLDER, f"{job_id}_animation.mp4")

    # Mock processing (replace with actual command)
    subprocess.run(["touch", animation_path])  # Replace with actual processing command

    job["status"] = "completed"
    job["animation_url"] = f"/results/{job_id}_animation.mp4"

if __name__ == '__main__':
    app.run(debug=True)
