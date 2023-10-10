== Installation

$ curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.25.0/install.sh | bash -s v0.25.0
$ kubectl create -f https://operatorhub.io/install/redis-operator.yaml
$ kubectl create -f RedisCluster.yaml
