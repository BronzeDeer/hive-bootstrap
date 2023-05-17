local keycloaksCRD = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/crds/legacy.k8s.keycloak.org_externalkeycloaks_crd.yaml');
local clientsCRD = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/crds/legacy.k8s.keycloak.org_keycloakclients_crd.yaml');
local realmsCRD = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/crds/legacy.k8s.keycloak.org_keycloakrealms_crd.yaml');
local usersCRD = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/crds/legacy.k8s.keycloak.org_keycloakusers_crd.yaml');

local deployment = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/operator.yaml');
local role = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/role.yaml');
local rolebinding = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/role_binding.yaml');
local sa = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-realm-operator/deploy/service_account.yaml');

[
  keycloaksCRD,
  clientsCRD,
  realmsCRD,
  usersCRD,
  deployment,
  role,
  rolebinding,
  sa,
]
