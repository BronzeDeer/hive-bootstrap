 local util = import '../../../lib/util.jsonnet';

 local install = std.parseYaml(importstr './submodule/manifests/install.yaml');

local filtered = util.findResource(install,name="argocd-cmd-params-cm",kind="ConfigMap");

[
  std.parseYaml(importstr './namespace.yaml'),
  filtered.match[0]
    # Disable self-signed TLS cert, TLS Termination will be handled at ingress
    + {data +:{"server.insecure":"TRUE"}}
]
+ filtered.rest
