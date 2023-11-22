# Local services provisioning
Set of manifests to simplify local development using dependent services and databases

Services can be run in docker context or in K8S minukube environment
- Docker with docker-compose
- K8S with helm (or terraform)

## Services
- MongoDB
- PostgreSQL
- Redis
- RabbitMQ
- NATS

## Kubernetes management tools
- Lightweight kubernetes https://k3s.io
- K3D   https://k3d.io/v5.6.0
- Lens  https://k8slens.dev
- K9S   https://k9scli.io

## Define global aliases (fish shell)

```shell
alias -s k="kubectl"
```
```shell
alias -s kgp="kubectl get pods"
```

## Setup minikube

https://minikube.sigs.k8s.io/docs/start

It will start minikube with 2 nodes
```bash
minikube start --nodes 2
```

### Point Docker CLI to minikube

```shell
eval $(minikube -p <profile> docker-env)
```
Fish:
```shell
minikube -p <profile> docker-env | source
```

## How to run services locally

### MongoDB

Connection: \
Ports: 27017 \
Credentials: 

```shell
cd ./mongodb
kubectl apply -f .
```
### PostgreSQL

Connection: \
Ports: 5432 \
Credentials:
```shell
POSTGRES_DB: postgresdb
POSTGRES_USER: admin
POSTGRES_PASSWORD: test123
```

```shell
cd ./potsgres
kubectl apply -f .
```

### Exposing services

#### PostgreSQL

To expose PostgreSQL to local server you need to change service kind to `LoadBalancer` instead of `NodePort`
and execute:

```shell
kubectl expose deployment postgres --type=LoadBalancer --name=postgres-exp
```

if you use minukube

```shell
minikube tunnel
```
or
```shell
make tunnel
```

#### MongoDB
// TBD

## Cheatsheets

Get all resources
```shell
kubectl get po -A
```

### Kubectl's context and configuration

```shell
kubectl config view # Show Merged kubeconfig settings.

# use multiple kubeconfig files at the same time and view merged config
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2

kubectl config view

# get the password for the e2e user
kubectl config view -o jsonpath='{.users[?(@.name == "e2e")].user.password}'

kubectl config view -o jsonpath='{.users[].name}'    # display the first user
kubectl config view -o jsonpath='{.users[*].name}'   # get a list of users
kubectl config get-contexts                          # display list of contexts
kubectl config current-context                       # display the current-context
kubectl config use-context my-cluster-name           # set the default context to my-cluster-name

# add a new user to your kubeconf that supports basic auth
kubectl config set-credentials kubeuser/foo.kubernetes.com --username=kubeuser --password=kubepassword

# permanently save the namespace for all subsequent kubectl commands in that context.
kubectl config set-context --current --namespace=ggckad-s2

# set a context utilizing a specific username and namespace.
kubectl config set-context gce --user=cluster-admin --namespace=foo \
  && kubectl config use-context gce

kubectl config unset users.foo                       # delete user foo

# short alias to set/show context/namespace (only works for bash and bash-compatible shells, current context to be set before using kn to set namespace) 
alias kx='f() { [ "$1" ] && kubectl config use-context $1 || kubectl config current-context ; } ; f'
alias kn='f() { [ "$1" ] && kubectl config set-context --current --namespace $1 || kubectl config view --minify | grep namespace | cut -d" " -f6 ; } ; f'
```

## Viewing, finding resources

```shell
# Get commands with basic output
kubectl get services                          # List all services in the namespace
kubectl get pods --all-namespaces             # List all pods in all namespaces
kubectl get pods -o wide                      # List all pods in the current namespace, with more details
kubectl get deployment my-dep                 # List a particular deployment
kubectl get pods                              # List all pods in the namespace
kubectl get pod my-pod -o yaml                # Get a pod's YAML

# Describe commands with verbose output
kubectl describe nodes my-node
kubectl describe pods my-pod

# List Services Sorted by Name
kubectl get services --sort-by=.metadata.name

# List pods Sorted by Restart Count
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'

# List PersistentVolumes sorted by capacity
kubectl get pv --sort-by=.spec.capacity.storage

# Get the version label of all pods with label app=cassandra
kubectl get pods --selector=app=cassandra -o \
  jsonpath='{.items[*].metadata.labels.version}'

# Retrieve the value of a key with dots, e.g. 'ca.crt'
kubectl get configmap myconfig \
  -o jsonpath='{.data.ca\.crt}'

# Get all worker nodes (use a selector to exclude results that have a label
# named 'node-role.kubernetes.io/control-plane')
kubectl get node --selector='!node-role.kubernetes.io/control-plane'

# Get all running pods in the namespace
kubectl get pods --field-selector=status.phase=Running

# Get ExternalIPs of all nodes
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

# List Names of Pods that belong to Particular RC
# "jq" command useful for transformations that are too complex for jsonpath, it can be found at https://stedolan.github.io/jq/
sel=${$(kubectl get rc my-rc --output=json | jq -j '.spec.selector | to_entries | .[] | "\(.key)=\(.value),"')%?}
echo $(kubectl get pods --selector=$sel --output=jsonpath={.items..metadata.name})

# Show labels for all pods (or any other Kubernetes object that supports labelling)
kubectl get pods --show-labels

# Check which nodes are ready
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
 && kubectl get nodes -o jsonpath="$JSONPATH" | grep "Ready=True"

# Output decoded secrets without external tools
kubectl get secret my-secret -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}'

# List all Secrets currently in use by a pod
kubectl get pods -o json | jq '.items[].spec.containers[].env[]?.valueFrom.secretKeyRef.name' | grep -v null | sort | uniq

# List all containerIDs of initContainer of all pods
# Helpful when cleaning up stopped containers, while avoiding removal of initContainers.
kubectl get pods --all-namespaces -o jsonpath='{range .items[*].status.initContainerStatuses[*]}{.containerID}{"\n"}{end}' | cut -d/ -f3

# List Events sorted by timestamp
kubectl get events --sort-by=.metadata.creationTimestamp

# Compares the current state of the cluster against the state that the cluster would be in if the manifest was applied.
kubectl diff -f ./my-manifest.yaml

# Produce a period-delimited tree of all keys returned for nodes
# Helpful when locating a key within a complex nested JSON structure
kubectl get nodes -o json | jq -c 'paths|join(".")'

# Produce a period-delimited tree of all keys returned for pods, etc
kubectl get pods -o json | jq -c 'paths|join(".")'

# Produce ENV for all pods, assuming you have a default container for the pods, default namespace and the `env` command is supported.
# Helpful when running any supported command across all pods, not just `env`
for pod in $(kubectl get po --output=jsonpath={.items..metadata.name}); do echo $pod && kubectl exec -it $pod -- env; done

# Get a deployment's status subresource
kubectl get deployment nginx-deployment --subresource=status
```

## Troubleshooting

### Shell autocompletion

Somtimes on MacOS machines you can see this kind of error:
```
complete:13: command not found: compdef
```

To fix it, you need to install `bash-completion` package:
```shell
brew install bash-completion
```

And add following lines to your `~/.zshrc file:`:
```
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
```

After that you can add autocompletion for kubectl:
```shell
source <(kubectl completion zsh)
alias k=kubectl
complete -F __start_kubectl k
```

If you are using zsh shell, alternatively, you can install `https://ohmyz.sh/#install` extension for zsh which will fix \
it and add `kubectl` plugin:

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Add this line to your `~/.zshrc` file:
```
plugins=(git kubectl)
```

### Pull image from private registry

####  Log in to Docker Hub

```shell
docker login
```
Review the file with your credentials:
```shell
cat ~/.docker/config.json
```

Output:
```
{
    "auths": {
        "https://index.docker.io/v1/": {
            "auth": "c3R...zE2"
        }
    }
}
```

#### Create a Secret based on existing Docker credentials

```shell
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=<path/to/.docker/config.json> \
    --type=kubernetes.io/dockerconfigjson
```

where `<path/to/.docker/config.json>` is the path to the Docker client configuration file.

If you need more control (for example, to set a namespace or a label on the new secret) \
then you can customise the Secret before storing it. Be sure to:

- set the name of the data item to `.dockerconfigjson`
- base64 encode the Docker configuration file and then paste that string, unbroken as the value for field `data[".dockerconfigjson"]`
- set type to `kubernetes.io/dockerconfigjson`

Example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: myregistrykey
  namespace: awesomeapps
data:
  .dockerconfigjson: UmVhbGx5IHJlYWxseSByZWVlZWVlZWVlZWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWxsbGxsbGxsbGxsbGxsbGxsbGxsbGxsbGxsbGxsbGx5eXl5eXl5eXl5eXl5eXl5eXl5eSBsbGxsbGxsbGxsbGxsbG9vb29vb29vb29vb29vb29vb29vb29vb29vb25ubm5ubm5ubm5ubm5ubm5ubm5ubm5ubmdnZ2dnZ2dnZ2dnZ2dnZ2dnZ2cgYXV0aCBrZXlzCg==
type: kubernetes.io/dockerconfigjson
```

#### Create a Secret by providing credentials on the command line
Create this Secret, naming it regcred:
```shell
kubectl create secret docker-registry regcred \
    --docker-server=<your-registry-server> \
    --docker-username=<your-name> \
    --docker-password=<your-pword> \
    --docker-email=<your-email>
```
where:
- `<your-registry-server>` is your Private Docker Registry FQDN. Use `https://index.docker.io/v1/` for DockerHub.
- `<your-name>` is your Docker username.
- `<your-pword>` is your Docker password.
- `<your-email>` is your Docker email.

#### Inspecting the Secret regcred
```shell
kubectl get secret regcred --output=yaml
```

```
apiVersion: v1
kind: Secret
metadata:
  ...
  name: regcred
  ...
data:
  .dockerconfigjson: eyJodHRwczovL2luZGV4L ... J0QUl6RTIifX0=
type: kubernetes.io/dockerconfigjson
```

The value of the `.dockerconfigjson` field is a base64 representation of your Docker credentials.\
To understand what is in the `.dockerconfigjson` field, convert the secret data to a readable format:

```shell
kubectl get secret regcred --output="jsonpath={.data.\.dockerconfigjson}" | base64 --decode
```

Output:
```
{"auths":{"your.private.registry.example.com":{"username":"janedoe","password":"xxxxxxxxxxx","email":"jdoe@example.com","auth":"c3R...zE2"}}}
```

To understand what is in the auth field, convert the base64-encoded data to a readable format:

```shell
echo c3R...zE2 | base64 --decode
```

The output, username and password concatenated with a :, is similar to this:
```
janedoe:xxxxxxxxxxx
```

Notice that the Secret data contains the authorization token similar to your local ~/.docker/config.json file.

#### Using the Secret

To use the Secret, refer to it in the imagePullSecrets field in the deployment configuration:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
    - name: private-reg-container
      image: <your-private-image>
  imagePullSecrets:
    - name: regcred
```

```shell
kubectl apply -f my-private-reg-pod.yaml
kubectl get pod private-reg
```

Also, in case the Pod fails to start with the status ImagePullBackOff, view the Pod events:
```shell
kubectl describe pod private-reg
```

## Helpers

### All open ports
```shell
lsof -i -P -n
```

### Specific port
```shell
lsof -i :5432
```
