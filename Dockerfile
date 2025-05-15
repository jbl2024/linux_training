FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Création de l'utilisateur
RUN useradd -ms /bin/bash appuser

# Installation minimale sans paquets orientés réseau
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim \
    vim-runtime \
    ttyd \
    locales \
    tzdata \
    man-db \
    ksh && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Variables d'environnement de locale
ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8

# Création du répertoire de tutoriels
RUN mkdir -p /home/appuser/tutoriels/

# Copie des fichiers
COPY ./tutoriels/* /home/appuser/tutoriels/

# Attribution des droits
RUN chown -R root:appuser /home/appuser/tutoriels

# Droits utilisateur
USER appuser
WORKDIR /home/appuser

# Port d’exposition pour ttyd
EXPOSE 7681

# Commande de lancement
CMD ["ttyd", "--writable", "bash"]
