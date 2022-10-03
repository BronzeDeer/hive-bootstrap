local install = std.parseYaml(importstr './install.yaml');


local k = import '../../lib/k.libsonnet';
local util = import '../../lib/util.jsonnet';

# Modify arguments passed to argo deployment
local argoDep = util.findResource(install,name="argo-server",kind="Deployment");

local dep = k.apps.v1.deployment;

local ing = k.networking.v1.ingress;
local ingRule = k.networking.v1.ingressRule;
local ingPath = k.networking.v1.httpIngressPath;

function(baseDomain)[
  std.parseYaml(importstr './namespace.yaml'),

  argoDep.match[0]
  + dep.spec.template.spec.withContainers([
      argoDep.match[0].spec.template.spec.containers[0]
      + k.core.v1.container.withArgs(["server","--insecure"])
  ])
  ,

  ing.new("argo-server")
  + ing.metadata.withNamespace("argo")
  + ing.spec.withRules([
      ingRule.withHost("argowf."+baseDomain)
      + ingRule.http.withPaths([
          ingPath.withPath("/")
          + ingPath.withPathType("Prefix")
          + ingPath.backend.service.withName("argo-server")
          + ingPath.backend.service.port.withName("web")
        ])
  ])
]
// Remove cert-manager resource not needed if we disable self-signed cert
+ util.findResource(argoDep.rest,apiVersion="cert-manager.io/v1").rest
