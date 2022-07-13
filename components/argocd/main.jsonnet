 local install = std.parseYaml(importstr './submodule/manifests/install.yaml');

[
  std.parseYaml(importstr './namespace.yaml'),
]
+ install
