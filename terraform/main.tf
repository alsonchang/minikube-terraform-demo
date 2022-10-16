# module "kube" {
#   source       = "./modules/kube-prometheus"
#   kube-version = "36.2.0"
# }

data "kubectl_file_documents" "namespace" {
  content = file("../manifests/argocd/namespace.yaml")
}

data "kubectl_file_documents" "argocd" {
  content = file("../manifests/argocd/install.yaml")
}

resource "kubectl_manifest" "namespace" {
  count              = length(data.kubectl_file_documents.namespace.documents)
  yaml_body          = element(data.kubectl_file_documents.namespace.documents, count.index)
  override_namespace = "argocd"
}

resource "kubectl_manifest" "argocd" {
  depends_on = [
    kubectl_manifest.namespace,
  ]
  count              = length(data.kubectl_file_documents.argocd.documents)
  yaml_body          = element(data.kubectl_file_documents.argocd.documents, count.index)
  override_namespace = "argocd"
}


# data "kubectl_file_documents" "my-nginx-app" {
#   content = file("../manifests/argocd/my-nginx-app.yaml")
# }

# resource "kubectl_manifest" "my-nginx-app" {
#   depends_on = [
#     kubectl_manifest.argocd,
#   ]
#   count              = length(data.kubectl_file_documents.my-nginx-app.documents)
#   yaml_body          = element(data.kubectl_file_documents.my-nginx-app.documents, count.index)
#   override_namespace = "argocd"
# }

data "kubectl_file_documents" "my-demo-app" {
  content = file("../manifests/argocd/my-demo-app.yaml")
}

resource "kubectl_manifest" "my-demo-app" {
  depends_on = [
    kubectl_manifest.argocd,
  ]
  count              = length(data.kubectl_file_documents.my-demo-app.documents)
  yaml_body          = element(data.kubectl_file_documents.my-demo-app.documents, count.index)
  override_namespace = "argocd"
}



