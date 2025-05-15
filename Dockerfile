FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -ms /bin/bash appuser

RUN apt-get update && \
    apt-get install -y \
    vim \
    vim-runtime \
    ttyd \
    locales \
    tzdata \
    man-db \
    sqlite3 \
    python3 \
    python3-pip \
    python3-venv \
    ksh \
    git && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8 \
    PATH="/home/appuser/agent/venv/bin:${PATH}"

RUN mkdir -p /home/appuser/tutoriels/ /home/appuser/agent
RUN python3 -m venv /home/appuser/agent/venv

COPY ./agent /home/appuser/agent/
COPY ./tutoriels/* /home/appuser/tutoriels/

RUN chown -R root:appuser /home/appuser/agent /home/appuser/tutoriels

RUN /home/appuser/agent/venv/bin/pip install --no-cache-dir -r /home/appuser/agent/requirements.txt && \
    cd /home/appuser/agent && \
    /home/appuser/agent/venv/bin/pip install -e .

USER appuser
WORKDIR /home/appuser

EXPOSE 7681
CMD ["ttyd", "--writable", "bash"]
