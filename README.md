# iac-terragrunt-template
Repository to use as a template for future terragrunt (IaC tool) projects.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Introduction
This repository is a template to be used for future terragrunt projects. It contains a basic structure for terragrunt projects and some basic modules to be used as examples.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [Justfile](https://just.systems)

## Getting Started
To get started, you can use this repository as a template and clone it to your local machine. After that, you can start creating your own modules and terragrunt configurations.

## Usage
Use the Justfile provided in this repository to run various commands. You can see the available commands by running `just --list`.

### Build the infrastructure folder structure
To build the infrastructure folder structure, run the following command:
*Make sure to set the desired account-ids, regions, environments in [build-folder-structure script](/scripts/build-folder-structure.sh)*
```bash
just build-folder-structure
```

#### Example:
```bash
infrastructures
├── 82281136
│   ├── account_commons.hcl
│   ├── dev
│   │   ├── dev-1
│   │   │   ├── us-east-1
│   │   │   │   ├── compute
│   │   │   │   │   └── compute_commons.hcl
│   │   │   │   ├── databases
│   │   │   │   │   └── databases_commons.hcl
│   │   │   │   ├── network
│   │   │   │   │   └── network_commons.hcl
│   │   │   │   ├── region_commons.hcl
│   │   │   │   ├── secrets
│   │   │   │   │   └── secrets_commons.hcl
│   │   │   │   └── storage
│   │   │   │       └── storage_commons.hcl
│   │   │   └── us-west-1
│   │   │       ├── compute
│   │   │       │   └── compute_commons.hcl
│   │   │       ├── databases
│   │   │       │   └── databases_commons.hcl
│   │   │       ├── network
│   │   │       │   └── network_commons.hcl
│   │   │       ├── region_commons.hcl
│   │   │       ├── secrets
│   │   │       │   └── secrets_commons.hcl
│   │   │       └── storage
│   │   │           └── storage_commons.hcl
│   │   └── environment_commons.hcl
│   ├── prod
│   │   ├── environment_commons.hcl
│   │   └── prod-1
│   │       ├── us-east-1
│   │       │   ├── compute
│   │       │   │   └── compute_commons.hcl
│   │       │   ├── databases
│   │       │   │   └── databases_commons.hcl
│   │       │   ├── network
│   │       │   │   └── network_commons.hcl
│          │   ├── region_commons.hcl
│   │       │   ├── secrets
│   │       │   │   └── secrets_commons.hcl
│   │       │   └── storage
│   │       │       └── storage_commons.hcl
│   │       └── us-west-1
│   │           ├── compute
│   │           │   └── compute_commons.hcl
│   │           ├── databases
│   │           │   └── databases_commons.hcl
│   │           ├── network
│   │           │   └── network_commons.hcl
│   │           ├── region_commons.hcl
│   │           ├── secrets
│   │           │   └── secrets_commons.hcl
│   │           └── storage
│   │               └── storage_commons.hcl
│   └── stage
│       ├── environment_commons.hcl
│       └── stage-1
│           ├── us-east-1
│           │   ├── compute
│           │   │   └── compute_commons.hcl
│           │   ├── databases
│           │   │   └── databases_commons.hcl
│           │   ├── network
│           │   │   └── network_commons.hcl
│           │   ├── region_commons.hcl
│           │   ├── secrets
│           │   │   └── secrets_commons.hcl
│           │   └── storage
│           │       └── storage_commons.hcl
│           └── us-west-1
│               ├── compute
│               │   └── compute_commons.hcl
│               ├── databases
│               │   └── databases_commons.hcl
│               ├── network
│               │   └── network_commons.hcl
│               ├── region_commons.hcl
│               ├── secrets
│               │   └── secrets_commons.hcl
│               └── storage
│                   └── storage_commons.hcl
└── infrastructure_commons.hcl

44 directories, 41 files
```

## Contributing
If you want to contribute to this repository, please create a pull request with your changes.

## License
This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

