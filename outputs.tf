# outputs.tf

output "name" {
  description = "VM Name"
  value       = { for k, vm in module.compute_instances : k => vm.*.instances_details[0].*.name }
}
