# Allow templating root app for different repoURL and revision

local argocd = import './vendor/github.com/jsonnet-libs/argo-cd-libsonnet/2.3/main.libsonnet';
local app = argocd.argoproj.v1alpha1.application;

local base_app = std.parseYaml(importstr './app.yaml' );


function(repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")

[
  base_app
  + app.spec.source.withRepoURL(repoURL)
  + app.spec.source.withTargetRevision(revision)

]
