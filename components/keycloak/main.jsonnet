// TODO: from TLAs
local baseURL = ".hive.bronze-deer.de";
[
  std.parseYaml(importstr './keycloak.yaml')
  + {
    spec+: {
      hostname+:{
        hostname: "keycloak"+baseURL,
      },
    },
  },
]
