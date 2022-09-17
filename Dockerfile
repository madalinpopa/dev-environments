FROM debian:11

# ********************************************************
# * Install needed packages and updates                  *
# ********************************************************
RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    vim \
    curl \
    sudo \
    man-db \
    locales \
    bash-completion \
    ca-certificates \
    apt-transport-https \
    software-properties-common

# ********************************************************
# * Install additional locale                            *
# ********************************************************
RUN rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

# ********************************************************
# * Create a non root user                               *
# ********************************************************
ENV USERNAME=vscode
ENV USER_UID=1000
ENV USER_GID=$USER_UID
# Create a passwordless user and sudo. This is for a local development
# environment. DON'T DO THIS IN PRODUCTION
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Install python3.9                                    *
# ********************************************************
RUN apt-get install --no-install-recommends -y python3-full \
    && apt-get install --no-install-recommends -y python3-pip

# ********************************************************
# * Install NVM and Nodejs                               *
# ********************************************************
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install --lts

# ********************************************************
# * Set the default user to run in container             *
# ********************************************************
USER "${USERNAME}"

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV PATH="/home/$USERNAME/.local/bin:${PATH}"

# ********************************************************
# * Clone and install the dotfiles                       *
# ********************************************************
RUN git clone https://github.com/madalinpopa/dotfiles.git ~/.dotfiles \
    && cd ~/.dotfiles \
    && ./install

# ********************************************************
# * Set the default working directory                    *
# ********************************************************
WORKDIR "/home/$USERNAME"
