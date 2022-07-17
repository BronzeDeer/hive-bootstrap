# TODO: replace with k8s-libsonnet
function(baseDomain){
    local domain = "argocd."+baseDomain,

    "apiVersion": "networking.k8s.io/v1",
    "kind": "Ingress",
    "metadata": {
        "name": "argocd",
        "namespace": "argocd",
    },
    "spec": {
        "rules": [
            {
                "host": domain,
                "http": {
                    "paths": [
                        {
                            "backend": {
                                "service": {
                                    "name": "argocd-server",
                                    "port": {
                                        "number": 80
                                    }
                                }
                            },
                            "path": "/",
                            "pathType": "Prefix"
                        }
                    ]
                }
            }
        ],
        "tls": [
            {
                "hosts": [
                    domain
                ],
            }
        ]
    },
}
