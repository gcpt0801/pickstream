packer {
  required_plugins {
    googlecompute = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "zone" {
  type        = string
  description = "GCP Zone"
  default     = "us-central1-a"
}

variable "source_image_family" {
  type        = string
  description = "Source image family"
  default     = "ubuntu-2204-lts"
}

variable "image_name" {
  type        = string
  description = "Name of the custom image"
  default     = "pickstream"
}

source "googlecompute" "webapp" {
  project_id          = var.project_id
  source_image_family = var.source_image_family
  zone                = var.zone
  image_name          = "${var.image_name}-{{timestamp}}"
  image_family        = var.image_name
  ssh_username        = "packer"
  machine_type        = "e2-medium"
  disk_size           = 20
  disk_type           = "pd-standard"
}

build {
  sources = ["source.googlecompute.webapp"]

  # Update system packages and enable universe repository
  provisioner "shell" {
    inline = [
      "sudo add-apt-repository -y universe",
      "sudo add-apt-repository -y multiverse",
      "sudo apt-get update",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y"
    ]
  }

  # Install Java 17 JDK (all dependencies will be installed automatically)
  provisioner "shell" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-17-jdk-headless",
      "java -version",
      "javac -version"
    ]
  }

  # Install Maven
  provisioner "shell" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y maven",
      "mvn -version"
    ]
  }

  # Install Tomcat 9
  provisioner "shell" {
    inline = [
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tomcat9 tomcat9-admin",
      "sudo systemctl enable tomcat9",
      "sudo systemctl stop tomcat9"
    ]
  }

  # Configure JAVA_HOME for Tomcat
  provisioner "shell" {
    inline = [
      "echo 'JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' | sudo tee -a /etc/default/tomcat9"
    ]
  }

  # Create deployment directory
  provisioner "shell" {
    inline = [
      "mkdir -p /tmp/webapp",
      "sudo mkdir -p /opt/webapp",
      "sudo chown -R tomcat:tomcat /opt/webapp"
    ]
  }

  # Copy pom.xml
  provisioner "file" {
    source      = "../pom.xml"
    destination = "/tmp/webapp/pom.xml"
  }

  # Copy source files
  provisioner "file" {
    source      = "../src"
    destination = "/tmp/webapp"
  }

  # Build and deploy application
  provisioner "shell" {
    inline = [
      "cd /tmp/webapp",
      "mvn clean package",
      "sudo cp target/random-names.war /var/lib/tomcat9/webapps/",
      "sudo chown tomcat:tomcat /var/lib/tomcat9/webapps/random-names.war"
    ]
  }

  # Create startup script
  provisioner "shell" {
    inline = [
      "sudo tee /opt/webapp/startup.sh > /dev/null <<'EOF'",
      "#!/bin/bash",
      "systemctl start tomcat9",
      "systemctl status tomcat9",
      "EOF",
      "sudo chmod +x /opt/webapp/startup.sh"
    ]
  }

  # Create systemd service for auto-start
  provisioner "shell" {
    inline = [
      "sudo systemctl enable tomcat9",
      "sudo systemctl restart tomcat9"
    ]
  }

  # Cleanup
  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /tmp/webapp",
      "rm -f ~/.bash_history",
      "sudo rm -f /root/.bash_history"
    ]
  }
}
