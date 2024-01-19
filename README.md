# aws-ec2-web-application

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-Assignment">About The Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
  </ol>
</details>



<!-- ABOUT THE ASSIGNMENT -->
## About The Assignment

This assignment is built to host a simple web application in AWS EC2 instance using Ansible and terraform.

<!-- GETTING STARTED -->
## Getting Started

### Prerequisites

* AWS account
* IAM user with access and secret access keys.
* Terraform

### Installation

1. Clone the repo
 
   git clone https://github.com/msdange/project_assignment_v0
 

<!-- USAGE -->
## Usage

Hosting the web application involves three parts.

### Part 1: Creating the Infrastructure

The infrastructure is created in AWS using Terraform.

1. cd into the AWS_Resources folder in the cloned repository.
2. Go to variables.tf file and change the values as per comments given and save the file.
3. Run the following commands in same order
    - terraform init
    - terraform plan
    - terraform apply

This will provision the required infrastructure and provides the ALB hostname as the output.

### Part 2: Installing the application

This is done using ansible.

1. a
2. b
3. Run the ansible playbook using the below command
    - ansible-playbook -i inventory.yml application.yml

### Part 3: Destroy the application after testing to save the cost

Run the below command to tear down the application.

    - terrafrom destroy
