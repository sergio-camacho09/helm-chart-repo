# Helm chart template 
### Challenge 1

In order to resolve this challenge, we will use [killercoda](https://killercoda.com/playgrounds/course/kubernetes-playgrounds/two-node) website as kubernetes lab. The selected one will be the playgroud with two nodes (2GB+2GB).

When we can see the kubernetes terminal, we will execute the following commands in order to test that challenge:

```sh
git clone https://github.com/sergio-camacho09/helm-chart-repo.git
cd helm-chart-repo && ./scripts/create-node-labels.sh
```

With this commands we will clone a repository than contains the technical test and then we will execute a script that will prepare the environment.
The script creates a new namespace to install our applications. Then, it obtains all cluster nodes and assign them labels that will be use for the challenge (the helm chart template will be responsible for this).

When we have executed this script, the next step will be execute the script that will install our random service and ping service:

```sh
./scripts/install-challenge-1.sh
