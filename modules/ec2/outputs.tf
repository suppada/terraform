output "tags" {
  description = "tags of all resources"
  value = {
    "Environment" = var.environment_tag
  }
}
output "instances" {
  value       = "${aws_instance.ec2_instance.*.private_ip}"
  description = "PrivateIP address details"
}