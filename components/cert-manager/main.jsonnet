local util = import '../../lib/util.jsonnet';

local cm = std.parseYaml(importstr './cert-manager.yaml');


#Mount optional aws creds

local filtered = util.findResource(cm, name="cert-manager", kind="Deployment");

# TODO: replace with k8s-libsonnet
local optionalAwsCreds = {
  secretRef: {
    name: "route53-acme-credentials",
    optional: true
  }
};

local container =
  filtered.match[0].spec.template.spec.containers[0]
  + {envFrom+: [optionalAwsCreds]}
  + {args+: ["--issuer-ambient-credentials"]};

[
  filtered.match[0]
  + { spec+: { template+: {spec+:{ containers: [container]}}}},
]
+ filtered.rest
