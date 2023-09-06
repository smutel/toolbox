# Installation

```bash
$ vagrant up
$ ./setup-kubespray.sh
$ cd kubespray && pipenv run ansible-playbook -i inventory/vagrant/hosts.yaml cluster.yml -u provision -b
```
