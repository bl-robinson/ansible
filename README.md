# Ansible Config repo

Most parts of this are deprecated now since my move to kubernetes, via terraform-k8s / home-flux repos.

This still exists though to maintain the 'physical hosts' which I still use.

Namely hv1/hv2 + Raspberry Pis (backup/shed-cam) (any others too)

Many of the roles are deprecated but keeping it around for physical hosts just helps me to bootstrap them for my network.


### Guide

This should be run simply on your local machine by...

ansible-playbook playbooks/<playbookfile> --inventory=hosts -e @secrets.enc --vault-password-file ansible-vault-key

(can just pass * to playbookfile if you want)
