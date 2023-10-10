== Installation

$ git clone git@github.com:zalando/postgres-operator.git
$ cd postgres-operator
$ git checkout v1.10.1
$ kubectl create -f manifests/configmap.yaml
$ kubectl create -f manifests/operator-service-account-rbac.yaml
$ kubectl create -f manifests/postgres-operator.yaml
$ kubectl create -f manifests/api-service.yaml
$ cd ..
$ kubectl create -f cluster.yaml
