FROM nvidia/cuda:11.8.0-devel-ubuntu22.04
#FROM debian:stable

# Install system packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y git python3-full python3-pip

# Create non-root user
RUN useradd -m -d /bark bark

# Run as new user
USER bark
WORKDIR /bark

# Clone git repo
RUN git clone https://github.com/C0untFloyd/bark-gui 

# Switch to git directory
WORKDIR /bark/bark-gui

# Create venv
RUN python3 -m venv /bark/venv

# Append pip bin path to PATH
ENV PATH=/bark/venv/bin:$PATH

# Install dependancies
RUN pip install .
RUN pip install -r requirements.txt
RUN pip install tensorboardX

# List on all addresses, since we are in a container.
RUN sed -i "s/server_name: ''/server_name: 0.0.0.0/g" ./config.yaml

# Suggested volumes
VOLUME /bark/bark-gui/assets/prompts/custom
VOLUME /bark/bark-gui/models
VOLUME /bark/.cache/huggingface/hub

# Default port for web-ui
EXPOSE 7860/tcp

# Start script
CMD python3 webui.py
