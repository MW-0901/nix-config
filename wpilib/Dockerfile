FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    openjdk-17-jdk \
    libusb-1.0-0 \
    aria2 \
    libgtk-3-0 \
    libx11-6 \
    libxss1 \
    libasound2 \
    libnss3 \
    libxkbfile1 \
    libsecret-1-0 \
    libgbm1 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    libxdamage1 \
    libxcomposite1 \
    libxcursor1 \
    libxi6 \
    libdrm2 \
    libxfixes3 \
    libgl1 \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -u 1000 -m -s /bin/bash mark

RUN cd /tmp && aria2c https://packages.wpilib.workers.dev/installer/v2026.1.1-beta-1/Linux/WPILib_Linux-2026.1.1-beta-1.tar.gz
RUN mkdir /wpilib
RUN tar -xzvf /tmp/WPILib_Linux-2026.1.1-beta-1.tar.gz -C /wpilib

RUN mkdir -p /home/mark/.wpilib_state && chown mark:mark /home/mark/.wpilib_state

RUN echo '#!/bin/bash\n'\
'mkdir -p ~/.wpilib_state\n'\
'touch ~/.wpilib_state/silenced\n'\
'echo "WPILib warning silenced. Restart your shell."' \
> /usr/local/bin/SILENCE_WPILIB_WARNING \
 && chmod +x /usr/local/bin/SILENCE_WPILIB_WARNING

RUN echo '\
if [ ! -f "$HOME/.wpilib_state/silenced" ]; then\n\
    PS1="PLEASE RUN /wpilib/*/WPILibInstaller, THEN RUN SILENCE_WPILIB_WARNING \\$ "\n\
fi\n' \
>> /etc/bash.bashrc

ENV ELECTRON_OZONE_PLATFORM_HINT=auto
ENV OZONE_PLATFORM=auto

USER mark
WORKDIR /home/mark
