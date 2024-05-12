terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}

provider "docker" {
  host     = "ssh://ansuser@192.168.0.19:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

resource "docker_image" "clickhouse" {
  name = "clickhouse/clickhouse-server:latest"
}

resource "docker_image" "clickhouse-keeper" {
  name = "clickhouse/clickhouse-keeper:latest-alpine"
}

resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}


# Executing an Ansible Playbook before Docker deployment
resource "null_resource" "ansible" {
  triggers = {
    docker_image_id = docker_image.clickhouse.image_id
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.ini plays/clickhouse.yml"
    working_dir = "/home/rifl/src/infra"
  }

  depends_on = [docker_image.clickhouse]
}


resource "docker_container" "clickhouse" {
  image             = docker_image.clickhouse.image_id
  name              = "grafana"
  must_run          = true
  restart           = "unless-stopped"

  volumes {
    host_path      = "/opt/files/clickhouse/config.xml"
    container_path = "/etc/clickhouse-server/config.d/config.xml"
  }
  ports {
    internal = 8123
    external = 8123
    ip       = "0.0.0.0"
  }

  ports {
    internal = 9000
    external = 9000
    ip       = "0.0.0.0"
  }

}

resource "docker_container" "grafana" {
  image             = docker_image.grafana.image_id
  name              = "clickhouse"
  must_run          = true
  restart           = "unless-stopped"

  ports {
    internal = 3000
    external = 3000
    ip       = "0.0.0.0"
  }
  env =[
  "GF_SECURITY_ADMIN_PASSWORD=password",
  "GF_SECURITY_ALLOW_EMBEDDING=true",
  "GF_AUTH_ANONYMOUS_ENABLED=true",
  "GF_AUTH_ANONYMOUS_ORG_ROLE=Admin",
  "GF_INSTALL_PLUGINS=grafana-clickhouse-datasource"
  ]
}
