# One shot install argo-cd and then let it manage itself and the rest of the cluster

local argo_cd = import './components/argocd/main.jsonnet';
local main = import './main.jsonnet';

function(baseDomain, acmeEmail, repoURL="https://github.com/BronzeDeer/hive-bootstrap",revision="HEAD")

argo_cd
+ main(baseDomain, acmeEmail, repoURL,revision)
