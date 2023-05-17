
local util = import '../../../lib/util.jsonnet';

local k = import '../../../lib/k.libsonnet';

local kcCRD = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-k8s-resources/kubernetes/keycloaks.k8s.keycloak.org-v1.yml');
local kcriCRD = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-k8s-resources/kubernetes/keycloakrealmimports.k8s.keycloak.org-v1.yml');
local otherManifests = std.parseYaml(importstr '../../../vendor/github.com/keycloak/keycloak-k8s-resources/kubernetes/kubernetes.yml');

local deployment = util.findResource(otherManifests,kind='Deployment');
// We need to patch the rolebindings to be clusterrole bindings
// However the better solution would be to export the keycloak-operator-role and view role bindings so each namespace deploying keycloaks has to "opt-in"
// to allowing access to its secrets etc via individual role-binding
// This can be accomplished either by an output variable on this module,
// or, if deploying from different git-repos, by creating a cross-plane composition and using claims to deploy the up-to-date set of rolebindings
local roleBindings = util.findResource(otherManifests, kind='RoleBinding');
// TODO: Get from TLAs
// local namespace = "keycloak";
// outputRoleBindings = std.map(function(rb)(
//   rb
//   + k.rbac.v1.roleBinding.withSubjects(
//     rb.subjects
//     + k.rbac.v1.subject.withNamespace(namespace)
//   )
// ), roleBindings)
// ;
local rbkc = util.findResource(deployment.rest, name='keycloakcontroller-role-binding');
local rbkcri = util.findResource(rbkc.rest, name='keycloakrealmimportcontroller-role-binding');
local rest = rbkcri.rest;

// TODO: Get from TLAs
local namespace = "keycloak";
[


  kcCRD,
  kcriCRD,

  // local container = deployment.match[0].spec.template.spec.containers[0];
  deployment.match[0]
  // + k.apps.v1.deployment.spec.template.spec.withContainers(
  //   container
  //   + k.core.v1.container.withEnvMixin([
  //   // Override the namespace limitation by overriding the value of KUBERNETES_NAMESPACE
  //     { name: "KUBERNETES_NAMESPACE", value: ""}
  //   ]
  //   )
  // )
  ,

  // Turn the role-bindings into cluster role bindings to allow the operator to manage CRDS in the whole cluster
  rbkc.match[0]
  + {kind: 'ClusterRoleBinding'}
  + k.rbac.v1.clusterRoleBinding.withSubjects(
    rbkc.match[0].subjects[0]
    + k.rbac.v1.subject.withNamespace(namespace)
  ),

  rbkcri.match[0]
  + {kind: 'ClusterRoleBinding'}
  + k.rbac.v1.clusterRoleBinding.withSubjects(
    rbkcri.match[0].subjects[0]
    + k.rbac.v1.subject.withNamespace(namespace)
  )
]
+ rest
