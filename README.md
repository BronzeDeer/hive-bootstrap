# hive-bootstrap
Bootstrap Manifests for the new K8s cluster "hive"

## Quickstart

Simply template and apply bootstrap.jsonnet against your cluster

```bash
jsonnet -y boostrap.jsonnet | kubectl -n argocd apply -f -
```

### Forks and Branches

If you want to apply a fork or branch of this repository, you can do this via TLAs

```bash
jsonnet -y --tla-str repoURL=https://github.com/mycool/fork.git --tla-str revision=my-branch boostrap.jsonnet | kubectl -n argocd apply -f -
```

## Uninstalling

First, remove the root app, which will cleanup all components except ArgoCD itself

```bash
kubectl -n argocd delete applications bootstrap
```

Then remove ArgoCD itself using bootstrap jsonnet

```bash
jsonnet -y bootstrap.jsonnet | kubectl -n argocd delete -f - --ignore-not-found
```
