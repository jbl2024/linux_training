FROM ubuntu:latest

# Créer un utilisateur non-root avec un répertoire personnel
RUN useradd -ms /bin/bash appuser

# Installer les dépendances nécessaires, configurer les locales, fuseau horaire, et restaurer le contenu minimisé
RUN apt-get update && \
    apt-get install -y vim vim-runtime ttyd locales tzdata man-db && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    unminimize && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurer les variables d'environnement pour la localisation en français
ENV LANG=fr_FR.UTF-8
ENV LANGUAGE=fr_FR:fr
ENV LC_ALL=fr_FR.UTF-8

# Changer les permissions du répertoire de l'utilisateur
RUN chown -R appuser:appuser /home/appuser

# Exposer le port par défaut de ttyd
EXPOSE 7681

# Passer à l'utilisateur non-root
USER appuser
WORKDIR /home/appuser

# Démarrer ttyd avec bash
CMD ["ttyd", "--writable", "bash"]
