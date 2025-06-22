
ansible-playbook site.yml -J --extra-vars "target=192.168.0.116"

ansible-playbook plays/fedora_os_release.yml -J --extra-vars "target=192.168.0.116,fedora_release=41"

ansible-playbook plays/os_update.yml 