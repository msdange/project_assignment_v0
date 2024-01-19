#!/bin/bash
sudo yum update -y
sudo yum install -y python3
sudo yum install -y python3-pip
sudo yum install -y ansible

# Copy the ansible-playbook to instance
sudo curl -o /home/ec2ansible.yaml -L https://github.com/msdange/project_assignment_v0/blob/main/ec2ansible.yaml

# Run the Ansible playbook
sudo ansible-playbook -i /home/inventory.ini -c /home/deploy_web_server.yaml