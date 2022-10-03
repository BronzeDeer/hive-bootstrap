local install = std.parseYaml(importstr './install.yaml');

local k = import '../../lib/k.libsonnet';

local ing = k.networking.v1.ingress;
local ingRule = k.networking.v1.ingressRule;
local ingPath = k.networking.v1.httpIngressPath;

function(baseDomain)
  install
  + [
    std.parseYaml(importstr './namespace.yaml'),

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
