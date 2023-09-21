#!/bin/bash
# Get the directory from the user
echo "Enter the directory where you want to create the Ansible project:(/home/babak)"
read directory

# Create the Ansible project directory
project_directory="${directory}/Ansible"
mkdir -p ${project_directory}

# Create the inventory file
echo "[myhosts]" > ${project_directory}/inventory.ini
echo "host1 ansible_host=192.168.1.2 ansible_user=username ansible_ssh_private_key_file=/path/to/private/key" >> ${project_directory}/inventory.ini

# Create the roles directory
mkdir -p ${project_directory}/roles/example_role/tasks

# Create a main.yml file in the tasks directory of the example_role
echo "---" > ${project_directory}/roles/example_role/tasks/main.yml
echo "- name: Example task" >> ${project_directory}/roles/example_role/tasks/main.yml
echo "  command: echo 'Hello, world!'" >> ${project_directory}/roles/example_role/tasks/main.yml

# Create a playbook that uses the example_role
echo "---" > ${project_directory}/playbook.yml
echo "- hosts: myhosts" >> ${project_directory}/playbook.yml
echo "  roles:" >> ${project_directory}/playbook.yml
echo "    - example_role" >> ${project_directory}/playbook.yml
echo "Ansible project has been created at ${project_directory}"
