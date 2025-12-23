variable "aks_cluster_id" {
  description = "AKS cluster ID to ensure ingress is installed after cluster creation"
  type        = string
}

variable "service_type" {
  description = "Type of Kubernetes service for ingress controller"
  type        = string
  default     = "LoadBalancer"
}

variable "external_traffic_policy" {
  description = "External traffic policy for ingress controller service (Cluster or Local)"
  type        = string
  default     = "Cluster"
}
