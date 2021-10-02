terraform {
    required_version = ">= 0.15"
    required_providers {
        linode = {
            source = "linode/linode"
            version = "1.16.0"
        }
    }
     backend "s3" {
        skip_credentials_validation = true
        skip_region_validation = true
    }
}

provider "linode" {
    token = var.linode_api_token
}


resource "linode_instance" "ai-as-an-api" {
        count = var.node_count
        image = "linode/ubuntu18.04"
        label = "ai-as-an-api-${count.index + 1}"
        group = "CFE-Learner"
        region = "us-east"
        type = "g6-nanode-1"
        root_pass = var.root_user_pw
        tags = [ "cfe", "api",]
        private_ip = true

        provisioner "file" {
            connection {
                host     = "${self.ip_address}"
                type     = "ssh"
                user     = "root"
                password = "${var.root_user_pw}"
            }
            source      = "${path.module}/bootstrap-docker.sh"
            destination = "/tmp/bootstrap-docker.sh"
        }

        provisioner "remote-exec" {
             connection {
                host     = "${self.ip_address}"
                type     = "ssh"
                user     = "root"
                password = "${var.root_user_pw}"
             }
             inline = [
                "chmod +x /tmp/bootstrap.sh",
                "/tmp/bootstrap.sh",
                "mkdir -p /var/www/",
                "git clone ${var.git_repo} /var/www/"
             ]
        }
        
        provisioner "remote-exec" {
             connection {
                host     = "${self.ip_address}"
                type     = "ssh"
                user     = "root"
                password = "${var.root_user_pw}"
             }
             inline = [
                "cd /var/www/",
                "docker build -t pyapp -f Dockerfile .",
                "docker run --restart always -e PORT=8000 -p 0.0.0.0:80:8000/tcp -d pyapp"
             ]
        }
        
}

resource "linode_nodebalancer" "ai-api-nb" {
    label = "mynodebalancer"
    region = "us-east"
    client_conn_throttle = 20
}

resource "linode_nodebalancer_config" "ai-api-nb-config" {
    nodebalancer_id = linode_nodebalancer.ai-api-nb.id
    port = 80
    protocol = "http"
    check = "http"
    check_path = "/"
    check_interval = 35
    check_attempts = 15
    check_timeout = 30
    stickiness = "http_cookie"
    algorithm = "source"
}

resource "linode_nodebalancer_node" "pynode" {
    count = var.node_count
    nodebalancer_id = linode_nodebalancer.ai-api-nb.id
    config_id = linode_nodebalancer_config.ai-api-nb-config.id
    address = "${element(linode_instance.ai-as-an-api.*.private_ip_address, count.index)}:80"
    label = "ai-api-nb-node-${count.index + 1}"
    weight = 50
}