FROM ubuntu:latest

# Créer un utilisateur non-root avec un répertoire personnel
RUN useradd -ms /bin/bash appuser

# Installer les dépendances nécessaires
RUN apt-get update && \
    apt-get install -y vim vim-runtime ttyd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Changer les permissions du répertoire de l'utilisateur
RUN chown -R appuser:appuser /home/appuser

# Exposer le port par défaut de ttyd
EXPOSE 7681

# Passer à l'utilisateur non-root
USER appuser
WORKDIR /home/appuser

# Démarrer ttyd avec bash
CMD ["ttyd", "--writable", "bash"]
