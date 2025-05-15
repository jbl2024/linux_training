FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Création de l'utilisateur non-root
RUN useradd -ms /bin/bash appuser

# Installation minimale + pare-feu + gosu
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim \
    vim-runtime \
    ttyd \
    locales \
    tzdata \
    man-db \
    ksh \
    iptables \
    gosu && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Variables de langue
ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8

# Tutoriels
RUN mkdir -p /home/appuser/tutoriels/
COPY ./tutoriels/* /home/appuser/tutoriels/
RUN chown -R root:appuser /home/appuser/tutoriels

# Port pour ttyd
EXPOSE 7681

# CMD final : configure iptables (en root), puis lance ttyd en appuser
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
