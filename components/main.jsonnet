local argocd = import '../vendor/github.com/jsonnet-libs/argo-cd-libsonnet/2.3/main.libsonnet';
local app = argocd.argoproj.v1alpha1.application;

local baseApp = function(name,repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")
  app.new(name)
  + app.spec.source.withRepoURL(repoURL)
  + app.spec.source.withTargetRevision(revision)
  + app.spec.destination.withServer("https://kubernetes.default.svc")
  + app.spec.withProject("default")
  + app.spec.syncPolicy.automated.withPrune(true)
  + app.spec.syncPolicy.automated.withSelfHeal(true)
;

function(baseDomain, acmeEmail, repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")

[
  baseApp("argo-cd",repoURL,revision)
  + app.spec.destination.withNamespace("argocd")
  + app.spec.source.withPath("./components/argocd/core")
  + app.spec.source.directory.withInclude("main.jsonnet"),

  baseApp("traefik",repoURL,revision)
  + app.spec.destination.withNamespace("traefik")
  + app.spec.source.withPath("./components/traefik/submodule/traefik")
  + app.spec.source.helm.withValueFilesMixin("../../values.yaml")
  + app.spec.syncPolicy.withSyncOptionsMixin("CreateNamespace=true"),

  baseApp("cert-manager",repoURL,revision)
  + app.spec.destination.withNamespace("cert-manager")
  + app.spec.source.withPath("./components/cert-manager")
  + app.spec.source.directory.withInclude("main.jsonnet"),

  baseApp("sealed-secrets-controller",repoURL,revision)
  + app.spec.destination.withNamespace("kube-system")
  + app.spec.source.withPath("./components/sealed-secrets/submodule/helm/sealed-secrets")
  + app.spec.syncPolicy.withSyncOptionsMixin("CreateNamespace=true")
  + app.spec.source.helm.withValueFilesMixin("../../../values.yaml"),

  baseApp("credentials",repoURL,revision)
  + app.spec.source.withPath("./credentials"),

  baseApp("tls",repoURL,revision)
  + app.spec.destination.withNamespace("traefik")
  + app.spec.source.withPath("./components/tls")
  + app.spec.source.directory.withInclude("main.jsonnet")
  + app.spec.source.directory.jsonnet.withTlasMixin({
    name: "baseDomain",
    value: baseDomain
  })
  + app.spec.source.directory.jsonnet.withTlasMixin({
    name: "acmeEmail",
    value: acmeEmail
  })
]
