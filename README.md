This should be run simply on your local machine by...

ansible-playbook playbooks/<playbookfile> --inventory=hosts -e @secrets.enc --vault-password-file ansible-vault-key

(can just pass * to playbookfile if you want)
