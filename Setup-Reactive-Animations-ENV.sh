#This script sets up the entire environment including cloning the repositories, setting up the virtual environment, and installing the necessary dependencies.
#!/bin/bash

set -e

# Function to log messages
log() {
    echo -e "\033[1;32m$1\033[0m"
}

# Function to handle errors
handle_error() {
    local lineno=$1
    local message=$2
    echo -e "\033[1;31mError occurred at line $lineno: $message. Exiting...\033[0m"
    exit 1
}

# Function to check if a directory exists and is not empty
check_directory() {
    local dir=$1
    if [ -d "$dir" ] && [ "$(ls -A $dir)" ]; then
        return 1
    else
        return 0
    fi
}

# Check dependencies
log "Checking dependencies..."

# Check for Git
if ! command -v git &>/dev/null; then
    log "Git is not installed. Installing..."
    sudo apt update
    sudo apt install -y git
fi

# Check for Python and pip
if ! command -v python3 &>/dev/null; then
    log "Python 3 is not installed. Installing..."
    sudo apt update
    sudo apt install -y python3
fi

if ! command -v pip3 &>/dev/null; then
    log "pip3 is not installed. Installing..."
    sudo apt update
    sudo apt install -y python3-pip
fi

# Check for Node.js and npm
if ! command -v node &>/dev/null; then
    log "Node.js is not installed. Installing..."
    sudo apt update
    sudo apt install -y nodejs
fi

if ! command -v npm &>/dev/null; then
    log "npm is not installed. Installing..."
    sudo apt update
    sudo apt install -y npm
fi

# Setup virtual environment
log "Setting up virtual environment..."
python3 -m venv env
source env/bin/activate

# Clone Repositories
log "Cloning repositories..."

repos=(
    "https://github.com/KaiberAI/animatediff-kaiber.git"
    "https://github.com/bucket-kim/kaiber-snapshot.git"
    "https://github.com/3rdevai/kaiber-backend.git"
    "https://github.com/3rdevai/Diff2GIF-Animated-Diffusion-Models.git"
    "https://github.com/3rdevai/AudioReactiveVideo.git"
)

directories=(
    "animatediff-kaiber"
    "kaiber-snapshot"
    "kaiber-backend"
    "Diff2GIF-Animated-Diffusion-Models"
    "AudioReactiveVideo"
)

for i in "${!repos[@]}"; do
    if check_directory "${directories[$i]}"; then
        git clone "${repos[$i]}" || handle_error $LINENO "Failed to clone ${repos[$i]}"
    else
        log "Directory ${directories[$i]} already exists and is not empty. Skipping clone."
    fi
done

# Setup Backend
log "Setting up the backend..."
cd backend
pip install -r requirements.txt || handle_error $LINENO "Failed to install backend dependencies"
cd ..

# Setup Frontend
log "Setting up the frontend..."
cd frontend
npm install || handle_error $LINENO "Failed to install frontend dependencies"
cd ..

log "Setup completed successfully."
