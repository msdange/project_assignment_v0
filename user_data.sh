#!/bin/bash

# Install Ansible & Dependancies
sudo yum install -y python3
sudo yum install -y python3-pip
sudo yum install -y openssh-client
sudo yum install -y ansible

# Create ansible playbook

cat <<EOF > /etc/ansible/ec2ansible.yaml
- hosts: localhost
  become: yes
  become_user: root
  tasks:
    - name: Update package manager cache
      yum:
        update_cache: yes

    - name: Install Apache web server
      yum:
        name: httpd
        state: present

    - name: Start Apache service
      service:
        name: httpd
        state: started

    - name: Enable Apache service
      service:
        name: httpd
        enabled: yes

    - name: copy index.html file
      copy:
        src: /etc/ansible/index.html
        dest: /var/www/html/index.html

    - name: Restart httpd service
      service:
        name: httpd
        state: restarted
EOF

# Create index.html file

cat <<EOF > /etc/ansible/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
</head>
<body>
    <header>
        <h1>Ansible playbook executed successfully!!</h1>
    </header>
    <main>
        <p>This is a sample HTML file for testing purposes.</p>
    </main>

</body>
</html>
EOF

# Run the Ansible playbook
sudo ansible-playbook -i "localhost," -c local /etc/ansible/ec2ansible.yaml