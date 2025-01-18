FROM ubuntu:latest

# Créer un utilisateur non-root avec un répertoire personnel
RUN useradd -ms /bin/bash appuser

# Installer les dépendances nécessaires, configurer les locales, fuseau horaire
RUN apt-get update && \
    apt-get install -y \
    vim \
    vim-runtime \
    ttyd \
    locales \
    tzdata \
    man-db \
    python3 \
    python3-pip \
    python3-venv && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurer les variables d'environnement pour la localisation en français
ENV LANG=fr_FR.UTF-8
ENV LANGUAGE=fr_FR:fr
ENV LC_ALL=fr_FR.UTF-8

# Créer la structure des répertoires
RUN mkdir /home/appuser/tutoriels/
RUN mkdir /home/appuser/agent

# Copier les fichiers du projet agent
COPY ./agent /home/appuser/agent/
COPY ./tutoriels/* /home/appuser/tutoriels/

# Configurer l'environnement Python et installer agent
RUN python3 -m venv /home/appuser/agent/venv && \
    chown -R appuser:appuser /home/appuser

# Passer à l'utilisateur non-root
USER appuser
WORKDIR /home/appuser

# Installer les dépendances et l'agent
RUN /home/appuser/agent/venv/bin/pip install -r /home/appuser/agent/requirements.txt && \
    cd /home/appuser/agent && \
    /home/appuser/agent/venv/bin/pip install -e .

# Ajouter le venv au PATH
ENV PATH="/home/appuser/agent/venv/bin:${PATH}"

# Exposer le port par défaut de ttyd
EXPOSE 7681

# Démarrer ttyd avec bash
CMD ["ttyd", "--writable", "bash"]
