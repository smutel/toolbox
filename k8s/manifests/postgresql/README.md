== Installation

$ git clone git@github.com:zalando/postgres-operator.git
$ git -C postgres-operator checkout v1.10.1
$ kubectl create namespace operator-postgres
$ sed -i 's/namespace: default/namespace: operator-postgres/g' postgres-operator/manifests/*
$ kubectl -n operator-postgres apply -f postgres-operator/manifests/configmap.yaml
$ kubectl -n operator-postgres apply -f postgres-operator/manifests/operator-service-account-rbac.yaml
$ kubectl -n operator-postgres apply -f postgres-operator/manifests/postgres-operator.yaml
$ kubectl -n operator-postgres apply -f postgres-operator/manifests/api-service.yaml
$ cd ..
$ kubectl create -f cluster.yaml
