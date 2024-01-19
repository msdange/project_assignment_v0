# aws-ec2-web-application

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-Assignment">About The Assignment</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
  </ol>
</details>



<!-- ABOUT THE ASSIGNMENT -->
## About The Assignment

This assignment is created to host a simple web application in AWS EC2 private instance using Ansible and terraform.

<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

* AWS account
* IAM user with access and secret access keys.
* EC2 .pem key
* Terraform

<!-- USAGE -->
## Usage

Hosting the web application involves three parts.

### Part 1: Creating the Infrastructure

The infrastructure is created in AWS using Terraform.

1. Ensure you have configured IAM user credentials using command : aws configure
2. Clone the repo
   ```sh
   git clone https://github.com/msdange/project_assignment_v0
   ```
3. cd into the cloned repository.
4. Go to variables.tf file and change the values as per comments given and Save the file.
5. Verify if given cidr blocks in main.tf are available in the AWS account. If not available update cidr blocks.
6. Run the following commands in same order
    - terraform init
    - terraform plan
    - terraform apply
 7. Above step will provision the required infrastructure and provides the ALB hostname as the output. Note the hostname.

### Part 2: Installing the application

This is done using ansible.

1. Go to AWS console > EC2 > select 'ansible_master' instance and click on connect
2. Note private ips of private ec2 instances and note alb host name (can be taken from 1st step)
3. Connect using EC2 instance connect and execute following commands
    - sudo su
    - cd /home
    - git clone https://github.com/msdange/project_assignment_v0
    - open inventory.ini file and make changes as mentioned in file comments
    - create .pem key file so that ansible_master instance can ssh into private instance
    - sudo vi ec2key.pem and add key
    - chmod 600 ec2key.pem
4. Run the ansible playbook using the below command
    - ansible-playbook -i inventory.ini ec2ansible.yml
5. Open LB DNS URL in web browser to see your ansible playbook ouput.

### Part 3: Destroy the application after testing to save the cost

Run the below command to tear down the application.

    - terrafrom destroy
