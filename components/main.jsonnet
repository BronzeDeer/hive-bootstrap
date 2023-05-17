local argocd = import '../vendor/github.com/jsonnet-libs/argo-cd-libsonnet/2.3/main.libsonnet';
local app = argocd.argoproj.v1alpha1.application;

local baseAppNoFinalizer = function(name,repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")
  app.new(name)
  + app.spec.source.withRepoURL(repoURL)
  + app.spec.source.withTargetRevision(revision)
  + app.spec.destination.withServer("https://kubernetes.default.svc")
  + app.spec.withProject("default")
  + app.spec.syncPolicy.automated.withPrune(true)
  + app.spec.syncPolicy.automated.withSelfHeal(true)
;

local baseApp = function(name,repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")
  baseAppNoFinalizer(name,repoURL,revision)
  + app.metadata.withFinalizersMixin("resources-finalizer.argocd.argoproj.io")
;

function(baseDomain, acmeEmail, repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")

[
  # No finalizer to avoid dead locking
  baseAppNoFinalizer("argo-cd",repoURL,revision)
  + app.spec.destination.withNamespace("argocd")
  + app.spec.source.withPath("./components/argocd/core")
  + app.spec.source.directory.withInclude("main.jsonnet"),

  baseApp("argo-cd-config",repoURL,revision)
  + app.spec.destination.withNamespace("argocd")
  + app.spec.source.withPath("./components/argocd/config")
  + app.spec.source.directory.withInclude("main.jsonnet")
  + app.spec.source.directory.jsonnet.withTlasMixin({
    name: "baseDomain",
    value: baseDomain
  }),

  baseApp("argo-wf",repoURL,revision)
  + app.spec.destination.withNamespace("argo")
  + app.spec.source.withPath("./components/argowf/")
  + app.spec.source.directory.withInclude("main.jsonnet")
  + app.spec.source.directory.jsonnet.withTlasMixin({
    name: "baseDomain",
    value: baseDomain
  }),

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
  }),

  baseApp("testkube", repoURL, revision)
  + app.spec.destination.withNamespace("testkube")
  + app.spec.source.withPath('./vendor/github.com/kubeshop/helm-charts/charts/testkube')
  + app.spec.source.helm.withValueFiles('../../../../../../components/testkube/values.yaml')
  + app.spec.syncPolicy.withSyncOptionsMixin('CreateNamespace=true'),


// To simplify the RBAC we deploy the operators and the keycloak into the same namespace
// This is not the best way to do it, refer to comment in keycloak-operator/new/main.jsonnet

  baseApp('keycloak-operator-new', repoURL, revision)
  + app.spec.destination.withNamespace('keycloak')
  + app.spec.source.withPath('./components/keycloak-operator/new/')
  + app.spec.source.directory.withInclude('main.jsonnet')
  + app.spec.syncPolicy.withSyncOptionsMixin('CreateNamespace=true')
  ,

  baseApp('keycloak-operator-legacy', repoURL, revision)
  + app.spec.destination.withNamespace('keycloak')
  + app.spec.source.withPath('./components/keycloak-operator/legacy/')
  + app.spec.source.directory.withInclude('main.jsonnet')
  ,

  baseApp('keycloak', repoURL, revision)
  + app.spec.destination.withNamespace('keycloak')
  + app.spec.source.withPath('./components/keycloak/')
  + app.spec.source.directory.withInclude('main.jsonnet')
  + app.spec.syncPolicy.withSyncOptionsMixin('CreateNamespace=true')
]
