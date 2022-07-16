local cm = import '../../vendor/github.com/jsonnet-libs/cert-manager-libsonnet/1.8/main.libsonnet';

local issuer = cm.nogroup.v1.issuer;
local solvers = issuer.spec.acme.solvers;
local cert = cm.nogroup.v1.certificate;


function(baseDomain, acmeEmail)
  local route53Solver = solvers.selector.withDnsZones(baseDomain)
    + solvers.dns01.route53.withRegion("eu-central-1");

  local iss = issuer.new("basedomain-issuer")
  + issuer.spec.acme.withServer("https://acme-v02.api.letsencrypt.org/directory")
  + issuer.spec.acme.withEmail(acmeEmail)
  + issuer.spec.acme.privateKeySecretRef.withName("lets-encrypt")
  + issuer.spec.acme.withSolvers(route53Solver);

  local crt = cert.new("basedomain-cert")
  + cert.spec.withSecretName("basedomain-cert")
  + cert.spec.withDnsNamesMixin([
    baseDomain,
    '*.'+baseDomain
  ])
  + cert.spec.issuerRef.withName(iss.metadata.name)
  + cert.spec.issuerRef.withKind(iss.kind);

[
  iss,
  crt,
  std.parseYaml(importstr './tls-store.yaml')
]
