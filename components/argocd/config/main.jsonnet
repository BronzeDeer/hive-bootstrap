local ingress = import './ingress.libsonnet';

function(baseDomain)
[
  ingress(baseDomain)
]
