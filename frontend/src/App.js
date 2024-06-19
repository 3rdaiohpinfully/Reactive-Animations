import React, { useState } from 'react';
import axios from 'axios';

const App = () => {
    const [audioFile, setAudioFile] = useState(null);
    const [status, setStatus] = useState("");
    const [animationUrl, setAnimationUrl] = useState("");

    const handleFileChange = (event) => {
        setAudioFile(event.target.files[0]);
    };

    const handleSubmit = async () => {
        const formData = new FormData();
        formData.append('audio', audioFile);

        try {
            setStatus("Uploading...");
            const response = await axios.post('/api/upload', formData);
            const { jobId } = response.data;

            setStatus("Processing...");
            const checkStatus = setInterval(async () => {
                const statusResponse = await axios.get(`/api/status/${jobId}`);
                if (statusResponse.data.status === "completed") {
                    setStatus("Completed");
                    setAnimationUrl(statusResponse.data.animationUrl);
                    clearInterval(checkStatus);
                }
            }, 5000);
        } catch (error) {
            setStatus("Error: " + error.message);
        }
    };

    return (
        <div>
            <h1>Audio Reactive Animation Generator</h1>
            <input type="file" onChange={handleFileChange} />
            <button onClick={handleSubmit}>Generate</button>
            <p>Status: {status}</p>
            {animationUrl && <a href={animationUrl} download>Download Animation</a>}
        </div>
    );
};

export default App;
