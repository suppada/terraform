output "tags" {
  description = "tags of all resources"
  value = {
    "Environment" = var.environment_tag
  }
}