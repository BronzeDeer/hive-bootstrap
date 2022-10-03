local install = std.parseYaml(importstr './submodule/manifests/quick-start-minimal.yaml');

local k = import '../../lib/k.libsonnet';

local ing = k.networking.v1.ingress

function(baseDomain){
  install
  + [
  ]
}
