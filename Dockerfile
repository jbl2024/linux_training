FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN useradd -ms /bin/bash appuser

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    vim \
    vim-runtime \
    ttyd \
    locales \
    tzdata \
    man-db \
    ksh \
    iptables && \
    locale-gen fr_FR.UTF-8 && \
    update-locale LANG=fr_FR.UTF-8 && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=fr_FR.UTF-8 \
    LANGUAGE=fr_FR:fr \
    LC_ALL=fr_FR.UTF-8

RUN mkdir -p /home/appuser/tutoriels/
COPY ./tutoriels/* /home/appuser/tutoriels/
RUN chown -R root:appuser /home/appuser/tutoriels

# Script firewall pour bloquer upload/download
RUN echo '#!/bin/bash\n\
iptables -F\n\
iptables -P OUTPUT DROP\n\
iptables -P INPUT DROP\n\
iptables -A INPUT -i lo -j ACCEPT\n\
iptables -A OUTPUT -o lo -j ACCEPT\n\
iptables -A INPUT -p tcp --dport 7681 -j ACCEPT\n\
iptables -A OUTPUT -p tcp --sport 7681 -j ACCEPT' > /etc/firewall.sh && \
    chmod +x /etc/firewall.sh

USER appuser
WORKDIR /home/appuser

EXPOSE 7681

CMD ["bash", "-c", "/etc/firewall.sh && ttyd --writable bash"]
