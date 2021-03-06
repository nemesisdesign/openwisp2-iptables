#!/bin/bash
# DO NOT EDIT THIS FILE BECAUSE IT IS AUTOMATICALLY GENERATED THROUGH ANSIBLE
echo "Resetting rules ..."
iptables --flush
iptables --delete-chain
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

# default policy
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD ACCEPT

# accept local
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# output (general)
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT  # dns
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT  # ssh
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT  # web
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT  # web-ssl
iptables -A OUTPUT -p tcp --dport 9418 -j ACCEPT  # git

# input (general)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport {{ openwisp2_iptables_ssh_port }} -j ACCEPT  # ssh
iptables -A INPUT -p tcp --dport 80 -j ACCEPT  # web
iptables -A INPUT -p tcp --dport 443 -j ACCEPT  # web-ssl

# allow ICMP and traceroute
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p udp --dport 33434:33524 -m state --state NEW -j ACCEPT

{% if openwisp2_iptables_vpn %}
# vpn specific
iptables -A INPUT -p udp --dport {{ openwisp2_iptables_vpn_port }} -j ACCEPT
iptables -A OUTPUT -o {{ openwisp2_iptables_vpn_interface }} -j ACCEPT  # vpn
# allow ICMP on vpn interface
iptables -A INPUT -p icmp -i {{ openwisp2_iptables_vpn_interface }} -j ACCEPT
iptables -A OUTPUT -p icmp -o {{ openwisp2_iptables_vpn_interface }} -j ACCEPT
{% endif %}

{% if openwisp2_iptables_additional_rules %}
# ADDITIONAL RULES
{% for rule in openwisp2_iptables_additional_rules %}
{{ rule }}
{% endfor %}
{% endif %}
