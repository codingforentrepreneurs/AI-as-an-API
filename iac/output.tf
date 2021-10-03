output "webapp_hosts" {
  value = [for host in linode_instance.cfe_ai_instance.*: "${host.label} : ${host.ip_address}"]
}

output "node_balancer_ip" {
    value = "${linode_nodebalancer.pycfeai.ipv4}"
}

output "node_balancer_hostname" {
    value = "${linode_nodebalancer.pycfeai.hostname}"
}