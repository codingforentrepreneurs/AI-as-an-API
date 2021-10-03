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


resource "linode_instance" "cfe_ai_instance" {
        count = var.node_count
        image = "linode/ubuntu18.04"
        label = "ai-as-an-api-${var.commit_id}-${count.index + 1}"
        group = "CFE-Learner"
        region = "us-east"
        type = "g6-standard-2"
        root_pass = var.root_user_pw
        tags = [ "cfe", "api",]
        private_ip = true

        lifecycle {
            create_before_destroy = true
        }
        

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
                "chmod +x /tmp/bootstrap-docker.sh",
                "/tmp/bootstrap-docker.sh",
                "mkdir -p /var/www/",
                "git clone ${var.git_repo} /var/www/"
             ]
        }

        provisioner "file" {
            connection {
                host     = "${self.ip_address}"
                type     = "ssh"
                user     = "root"
                password = "${var.root_user_pw}"
            }
            source      = "${local.root_dir}/.env"
            destination = "/var/www/.env"
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

resource "linode_nodebalancer" "pycfeai" {
    label = "cfe-ai-as-api-nodebalancer"
    region = "us-east"
    client_conn_throttle = 20
    depends_on = [
        linode_instance.cfe_ai_instance
    ]
}

resource "linode_nodebalancer_config" "pycfenbfig" {
    nodebalancer_id = linode_nodebalancer.pycfeai.id
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

resource "linode_nodebalancer_node" "ai_nodeblanacer" {
    count = var.node_count
    nodebalancer_id = linode_nodebalancer.pycfeai.id
    config_id = linode_nodebalancer_config.pycfenbfig.id
    address = "${element(linode_instance.cfe_ai_instance.*.private_ip_address, count.index)}:80"
    label = "cfe-ai-nb-node-${var.commit_id}-${count.index + 1}"
    weight = 50
    mode = "accept"
}