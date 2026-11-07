# Ansible Config repo

Most of my services now run on Kubernetes (via the terraform-k8s / home-flux repos).
This repo only maintains the physical hosts, mainly to bootstrap them onto my network.

### Hosts (`hosts`)

| Host     | What                                   | Address                          |
|----------|----------------------------------------|----------------------------------|
| hv1      | Hypervisor                             | 10.0.0.5                         |
| hv2      | Hypervisor                             | 10.0.0.19                        |
| data     | Pi, ZFS data / NFS server              | 10.0.0.3                         |
| backup   | Pi at a remote house, ZFS replica + HA | 192.168.0.200, WireGuard 10.0.2.4 |
| shed-cam | Pi, camera (Wi-Fi)                     | 10.0.0.2                         |

### Playbooks

| Playbook             | Targets       | Purpose                                           |
|----------------------|---------------|---------------------------------------------------|
| `core.yml`           | all           | Network config, base packages, SSH keys, cron mail |
| `hypervisor.yml`     | hv1, hv2      | qemu/libvirt                                      |
| `nfs-server.yml`     | data          | NFS exports                                       |
| `pi_metrics.yml`     | data, backup  | node_exporter + smartctl_exporter (scraped by k8s Prometheus) |
| `zfs_snapshots.yml`  | data, backup  | sanoid snapshot retention                          |
| `home_assistant.yml` | backup        | Home Assistant container                          |

Not managed here (yet): WireGuard on `backup`.

### Guide

Run from your local machine:

    ansible-playbook playbooks/<playbookfile> --inventory=hosts -e @secrets.enc --vault-password-file ansible-vault-key

(you can pass `playbooks/*.yml` to run everything)
