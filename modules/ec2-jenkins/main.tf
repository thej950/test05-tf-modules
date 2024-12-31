
/*
resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = "Jenkins-Server"
  }
}

output "public_ip" {
  value = aws_instance.jenkins.public_ip
}
*/

resource "aws_instance" "jenkins" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  # User data script to download and execute the Jenkins setup script
  user_data = <<-EOF
#!/bin/bash

# Define log file
LOG_FILE="/var/log/install_jenkins.log"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

log "Starting Jenkins installation script."

# Update package list
log "Updating package list..."
if sudo apt-get update -y >> "$LOG_FILE" 2>&1; then
    log "Package list updated successfully."
else
    log "Failed to update package list. Exiting."
    exit 1
fi

# Set hostname
log "Setting hostname to Jenkins..."
if sudo hostnamectl set-hostname Jenkins >> "$LOG_FILE" 2>&1; then
    log "Hostname set to Jenkins."
else
    log "Failed to set hostname. Exiting."
    exit 1
fi

# Install OpenJDK 11
log "Installing OpenJDK 11..."
if sudo apt-get install openjdk-11-jdk -y >> "$LOG_FILE" 2>&1; then
    log "OpenJDK 11 installed successfully."
else
    log "Failed to install OpenJDK 11. Exiting."
    exit 1
fi

# Install Maven and Git
log "Installing Maven and Git..."
if sudo apt-get install maven git -y >> "$LOG_FILE" 2>&1; then
    log "Maven and Git installed successfully."
else
    log "Failed to install Maven and Git. Exiting."
    exit 1
fi

# Add Jenkins repository and key
log "Adding Jenkins repository key and source..."
if curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null && \
   echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null; then
    log "Jenkins repository key and source added successfully."
else
    log "Failed to add Jenkins repository key and source. Exiting."
    exit 1
fi

# Update package list again after adding Jenkins repo
log "Updating package list after adding Jenkins repository..."
if sudo apt-get update -y >> "$LOG_FILE" 2>&1; then
    log "Package list updated successfully."
else
    log "Failed to update package list after adding Jenkins repository. Exiting."
    exit 1
fi

# Install Jenkins
log "Installing Jenkins..."
if sudo apt-get install jenkins -y >> "$LOG_FILE" 2>&1; then
    log "Jenkins installed successfully."
else
    log "Failed to install Jenkins. Exiting."
    exit 1
fi

# Check if Jenkins service is running
log "Checking Jenkins service status..."
if sudo systemctl status jenkins | grep "active (running)" >> "$LOG_FILE" 2>&1; then
    log "Jenkins is running successfully."
else
    log "Jenkins service is not running. Please check the logs for more details."
    exit 1
fi

log "Jenkins installation script completed successfully."

EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

output "public_ip" {
  value = aws_instance.jenkins.public_ip
}