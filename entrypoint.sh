#!/bin/bash
# Configurer le pare-feu en tant que root
iptables -F
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -p tcp --dport 7681 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 7681 -j ACCEPT

# Passer à l'utilisateur non-privilégié pour ttyd
exec gosu appuser ttyd --writable bash
