
# OpenStack Tools

A collection of Bash and Python scripts designed to automate and manage various OpenStack tasks. These scripts are intended to streamline the management of OpenStack environments, including instance operations, port security, and security group transformations.

## Table of Contents

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Scripts](#scripts)
  - [Bash Scripts](#bash-scripts)
  - [Python Scripts](#python-scripts)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This repository contains a set of scripts written in Bash and Python to assist with the administration of OpenStack environments. The scripts are aimed at automating repetitive tasks and facilitating faster management of OpenStack instances, security groups, and ports.

## Requirements

Before using the scripts, ensure the following:

- An OpenStack environment is set up and configured.
- The OpenStack RC file (credentials) is sourced.
- You have necessary privileges to manage instances, security groups, and ports in the OpenStack environment.

## Scripts

### Bash Scripts

1. **`disableportsec.sh`**  
   Disables port security on specified ports in OpenStack.

   **Usage:**  
   `bash disableportsec.sh <port-id>`

2. **`startandstop_host_instances.sh`**  
   Starts and stops instances running on a specific host in OpenStack.

   **Usage:**  
   `bash startandstop_host_instances.sh <host-name> <start/stop>`

3. **`transformsecgroup.sh`**  
   Transforms security groups for specified instances to ensure appropriate security settings.

   **Usage:**  
   `bash transformsecgroup.sh <instance-id> <security-group-id>`

4. **`unlock_unpause.sh`**  
   Unlocks and unpauses a specified instance, resuming its operation.

   **Usage:**  
   `bash unlock_unpause.sh <instance-id>`

### Python Scripts

1. **`pauseanlock.py`**  
   Pauses and locks a specified instance in OpenStack.

   **Usage:**  
   `python pauseanlock.py <instance-id>`

2. **`unpauseunlock.py`**  
   Unpauses and unlocks a specified instance to resume its normal state.

   **Usage:**  
   `python unpauseunlock.py <instance-id>`

## Usage

1. **Set up OpenStack credentials**  
   Ensure that you source your OpenStack RC file before executing any scripts:

   ```bash
   source <your-openstack-rc-file>
   ```

2. **Execute the desired script**  
   Choose the appropriate script based on the task you want to perform, and execute it with the necessary parameters.

## Contributing

Contributions to this repository are welcome. If you would like to improve or add new features, please follow these steps:

1. Fork this repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -am 'Add new feature'`).
4. Push to the branch (`git push origin feature-name`).
5. Create a new Pull Request.

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for more details.
