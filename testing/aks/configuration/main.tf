resource "kubernetes_manifest" "storageclass" {
  manifest = yamldecode(file(var.storage_class_path))
}