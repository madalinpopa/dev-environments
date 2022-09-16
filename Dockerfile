FROM debian:11

# Update the system and install the needed packages
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    vim \
    curl \
    sudo \
    man-db \
    bash-completion \
    ca-certificates \
    apt-transport-https \
    software-properties-common

# Create an environment variable to hold the user
ENV DOCKER_USER vscode

# Create a passwordless user and sudo. This is for a local development
# environment. DON'T DO THIS IN PRODUCTION
RUN adduser --disabled-password --gecos '' "${DOCKER_USER}" \
    && adduser "${DOCKER_USER}" sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install python3.9
RUN apt-get install --no-install-recommends -y python3-full \
    && apt-get install --no-install-recommends -y python3-pip

# Install NVM and Nodejs
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install --lts

# Set the user to be our newly created user by default.
USER "${DOCKER_USER}"

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PATH="/home/${DOCKER_USER}/.local/bin:${PATH}"

# Clone and setup the dotfiles
RUN git clone https://github.com/madalinpopa/dotfiles.git ~/.dotfiles \
    && cd ~/.dotfiles \
    && ./install

# This will determine where we will start when we enter the container.
WORKDIR "/home/${DOCKER_USER}"
