output "webapp_hosts" {
  value = [for host in linode_instance.ai-as-an-api.*: "${host.label} : ${host.ip_address}"]
}

output "node_balancer_ip" {
    value = "${linode_nodebalancer.ai-api-nb.ipv4}"
}

output "node_balancer_hostname" {
    value = "${linode_nodebalancer.ai-api-nb.hostname}"
}