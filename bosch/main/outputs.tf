output "vm_credentials" {
  value = [
    for i in range(length(random_password.vm_passwords)) : {
      vm_name = azurerm_virtual_machine.main[i].name
      password = nonsensitive(random_password.vm_passwords[i].result)
      ping_output = trimspace(azurerm_virtual_machine_run_command.ping[i].instance_view[0].output)
    }
  ]
  sensitive = false
}

output "ping_outputs" {
  value = [for test in azurerm_virtual_machine_run_command.ping : trimspace(test.instance_view[0].output)]
}
