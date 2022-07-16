local cm = std.parseYaml(importstr './cert-manager.yaml');

# Allows pulling out specific resources from an object stream for further modification
local findResource = function(list,name=null,apiVersion=null,kind=null){
  local matchfun = function(resource)(
    ( name == null || resource.metadata.name == name)
    && ( apiVersion == null || resource.apiVersion == apiVersion)
    && ( kind == null || resource.kind == kind)
  ),
  match: std.filter(matchfun,list),
  rest: std.filter(function(resource) !matchfun(resource),list),
};

#Mount optional aws creds

local filtered = findResource(cm, name="cert-manager", kind="Deployment");

# TODO: replace with k8s-libsonnet
local optionalAwsCreds = {
  secretRef: {
    name: "route53-acme-credentials",
    optional: true
  }
};

local container =
  filtered.match[0].spec.template.spec.containers[0]
  + {envFrom+: [optionalAwsCreds]};


[
  filtered.match[0]
  + { spec+: { template+: {spec+:{ containers: [container]}}}},
]
+ filtered.rest
