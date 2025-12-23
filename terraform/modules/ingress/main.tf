resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.9.0"

  set {
    name  = "controller.service.type"
    value = var.service_type
  }

  dynamic "set" {
    for_each = var.service_type != "ClusterIP" ? [1] : []
    content {
      name  = "controller.service.externalTrafficPolicy"
      value = var.external_traffic_policy
    }
  }

  depends_on = [
    var.aks_cluster_id
  ]
}

