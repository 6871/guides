# MicroK8s Setup & Remote Access

* [1. Install](#1-install)
    * [1.1. MicroK8s](#11-microk8s)
    * [1.2. kubectl](#12-kubectl)
* [2. Enable Services](#2-enable-services)
* [3. Remote Access](#3-remote-access)
    * [3.1. Get kubeconfig file](#31-get-kubeconfig-file)
    * [3.2. Use kubeconfig file](#32-use-kubeconfig-file)
    * [3.3. Dashboard Remote Access](#33-dashboard-remote-access)
* [4. References](#4-references)

# 1. Install

The `kubectl` and MicroK8s installs must be version compatible; see:
https://kubernetes.io/releases/version-skew-policy/#kubectl

## 1.1. MicroK8s

Some install options are:

* Select in Ubuntu installer's default software package list
* Install with `snap` as per https://microk8s.io/docs

To show MicroK8s version:

```
snap list | grep microk8s
snap info microk8s | grep installed
```

## 1.2. kubectl

Some install options are:

* Use version installed by macOS [Docker](https://www.docker.com/products/docker-desktop) installer
* Install manually as per https://kubernetes.io/docs/tasks/tools/#kubectl

To show kubectl version:

```
kubectl version
```

# 2. Enable Services

Run `microk8s enable` to enable services; for example:

```
microk8s enable dns dashboard storage
```

Some services may take a minute or two to start.

View service status with:

```
microk8s status
```

Use `microk8s kubectl` to run local operations; for example:

```
microk8s kubectl get all --all-namespaces
```

# 3. Remote Access

## 3.1. Get kubeconfig file

Obtain `kubeconfig` file on MicroK8s host with:

```
microk8s config > "${HOME}/microk8s-config"
chmod 600 "${HOME}/microk8s-config"
```

## 3.2. Use kubeconfig file

Copy `kubeconfig` file to `kubectl` host and use as follows:

```
kubectl --kubeconfig=microk8s-config version
kubectl --kubeconfig=microk8s-config get all --all-namespaces
```

## 3.3. Dashboard Remote Access

Obtain the dashboard service's login token from the MicroK8s host with:

```
token=$(microk8s kubectl --namespace kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl --namespace kube-system describe secret "${token}"
```

Forward a local port to the remote dashboard service with:

```
kubectl \
    --kubeconfig=microk8s-config \
    --namespace kube-system \
    port-forward service/kubernetes-dashboard 8443:443
```

Login with a web browser at: [https://localhost:8443](https://localhost:8443)

> Safari objects to untrusted certificate; Firefox grumbles but allows access.

# 4. References

* MicroK8s: https://microk8s.io
* `kubectl`: https://kubernetes.io/docs/reference/kubectl/
