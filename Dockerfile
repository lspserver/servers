FROM ubuntu:20.04

USER root
ARG GID=1000
ARG UID=1000
ARG APT="http://cn.archive.ubuntu.com/ubuntu/"
ARG LANG_EN="en_US.UTF-8"
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "deb $APT focal main multiverse restricted universe" | tee /etc/apt/sources.list && \
    echo "deb $APT focal-backports main multiverse restricted universe" | tee --append /etc/apt/sources.list && \
    echo "deb $APT focal-security main multiverse restricted universe" | tee --append /etc/apt/sources.list && \
    echo "deb $APT focal-updates main multiverse restricted universe" | tee --append /etc/apt/sources.list
RUN apt update -y && \
    apt install -y build-essential clang cmake curl file git libclang-10-dev libncurses-dev locales lsof m4 make net-tools nodejs npm && \
    apt install -y patch python3 python3-pip rapidjson-dev software-properties-common sudo unzip upx vim wget zip zlib1g-dev
RUN apt autoremove --purge -y > /dev/null && \
    apt autoclean -y > /dev/null && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/* && \
    rm -rf /tmp/*
RUN cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    echo "LC_ALL=$LANG_EN" >> /etc/environment && \
    echo "LANG=$LANG_EN" > /etc/locale.conf && \
    echo "$LANG_EN UTF-8" >> /etc/locale.gen && \
    echo "StrictHostKeyChecking no" | tee --append /etc/ssh/ssh_config && \
    echo "craftslab ALL=(ALL) NOPASSWD: ALL" | tee --append /etc/sudoers && \
    echo "dash dash/sh boolean false" | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash && \
    groupadd -g $GID craftslab && \
    useradd -d /home/craftslab -ms /bin/bash -g craftslab -u $UID craftslab
RUN locale-gen $LANG_EN && \
    update-locale LC_ALL=$LANG_EN LANG=$LANG_EN
ENV LANG=$LANG_EN
ENV LC_ALL=$LANG_EN
ENV SHELL="/bin/bash"

USER craftslab
WORKDIR /home/craftslab
RUN git clone --depth=1 --recursive https://github.com/MaskRay/ccls && \
    cd ccls && \
    cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10 -DLLVM_INCLUDE_DIR=/usr/lib/llvm-10/include -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10 && \
    cmake --build Release
ENV PATH=/home/craftslab/ccls/Release:$PATH

USER craftslab
WORKDIR /home/craftslab
RUN npm install bash-language-server dockerfile-language-server-nodejs typescript typescript-language-server vscode-css-languageserver-bin vscode-html-languageserver-bin

USER craftslab
WORKDIR /home/craftslab
RUN pip3 install 'python-language-server[all]'

USER craftslab
WORKDIR /home/craftslab
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source $HOME/.cargo/env && \
    rustup component add rls rust-analysis rust-src

USER craftslab
WORKDIR /home/craftslab