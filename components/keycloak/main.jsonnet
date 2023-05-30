// TODO: from TLAs
local baseURL = ".hive.bronze-deer.de";
local hostname = "keycloak"+baseURL;
[
  std.parseYaml(importstr './keycloak.yaml')
  + {
    spec+: {
      hostname+:{
        hostname: hostname,
      },
    },
  },
    std.parseYaml(importstr './external-keycloak.yaml')
  + {
    spec+: {
      url: hostname,
      },
  },
]
