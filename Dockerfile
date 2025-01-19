FROM ubuntu:latest

# Éviter les prompts interactifs pendant l'installation
ENV DEBIAN_FRONTEND=noninteractive

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
    sqlite3 \
    python3 \
    python3-pip \
    python3-venv \
    git && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurer les variables d'environnement pour la localisation en français
ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8 \
    PATH="/home/appuser/agent/venv/bin:${PATH}"

# Créer la structure des répertoires
RUN mkdir -p /home/appuser/tutoriels/ /home/appuser/agent

# Configurer l'environnement Python
RUN python3 -m venv /home/appuser/agent/venv

# Copier les fichiers du projet
COPY ./agent /home/appuser/agent/
COPY ./tutoriels/* /home/appuser/tutoriels/

# Donner temporairement les droits à appuser pour l'installation
RUN chown -R appuser:appuser /home/appuser

# Passer à l'utilisateur non-root pour l'installation
USER appuser
WORKDIR /home/appuser

# Installer les dépendances et l'agent
RUN /home/appuser/agent/venv/bin/pip install --no-cache-dir -r /home/appuser/agent/requirements.txt && \
    cd /home/appuser/agent && \
    /home/appuser/agent/venv/bin/pip install -e .

# Repasser en root pour configurer les permissions finales
USER root

# Configurer les permissions finales : lecture seule pour agent et tutoriels
RUN chown -R root:appuser /home/appuser/agent /home/appuser/tutoriels

# Repasser à l'utilisateur non-root pour l'exécution
USER appuser
WORKDIR /home/appuser

# Exposer le port par défaut de ttyd
EXPOSE 7681

# Démarrer ttyd avec bash
CMD ["ttyd", "--writable", "bash"]
