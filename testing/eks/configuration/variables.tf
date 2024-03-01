variable "region" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_autoscaler_helm_values" {
  type = string
}

variable "cluster_autoscaler_version" {
  type = string
}

variable "load_balancer_controller_helm_values" {
  type = string
}

variable "storage_class_path_gp2" {
  type = string
}

variable "storage_class_path_gp3" {
  type = string
}