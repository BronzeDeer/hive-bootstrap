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

function(repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")

[
  baseApp("argo-cd",repoURL,revision)
  + app.spec.destination.withNamespace("argocd")
  + app.spec.source.withPath("./components/argocd")
  + app.spec.source.directory.withInclude("main.jsonnet"),

]
