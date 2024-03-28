# iac-terragrunt-template
Repository to use as a template for future terragrunt (IaC tool) projects.

## Table of Contents
- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Build the infrastructure folder structure](#build-the-infrastructure-folder-structure)
- [Example](#example)
- [Inheritance](#inheritance)
- [Contributing](#contributing)
- [License](#license)

## Introduction
This repository is a template to be used for future terragrunt projects. It contains a basic structure for terragrunt projects and some basic modules to be used as examples.

## Prerequisites
- [Terraform](https://www.terraform.io/downloads.html)
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [Justfile](https://just.systems)
- [dot](https://graphviz.org/download/)
- [terraform-docs](https://terraform-docs.io/)

Can be install using:
```bash
brew install terraform terragrunt awscli just graphviz terraform-docs
```

## Getting Started
To get started, you can use this repository as a template and clone it to your local machine. After that, you can start creating your own modules and terragrunt configurations.

## Cheat Sheet
Make sure to check the [Cheat Sheet](/CheatSheet.md) for some useful commands and tips.

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
infrastructure-live
├── 82281136
│   ├── account.hcl
│   ├── dev
│   │   ├── dev-1
│   │   │   ├── us-east-1
│   │   │   │   ├── compute
│   │   │   │   │   └── compute
│   │   │   │   ├── databases
│   │   │   │   │   └── databases
│   │   │   │   ├── network
│   │   │   │   │   └── network
│   │   │   │   ├── region.hcl
│   │   │   │   ├── secrets
│   │   │   │   │   └── secrets
│   │   │   │   └── storage
│   │   │   │       └── storage
│   │   │   └── us-west-1
│   │   │       ├── compute
│   │   │       │   └── compute
│   │   │       ├── databases
│   │   │       │   └── databases
│   │   │       ├── network
│   │   │       │   └── network
│   │   │       ├── region.hcl
│   │   │       ├── secrets
│   │   │       │   └── secrets
│   │   │       └── storage
│   │   │           └── storage
│   │   └── env.hcl
│   ├── prod
│   │   ├── env.hcl
│   │   └── prod-1
│   │       ├── us-east-1
│   │       │   ├── compute
│   │       │   │   └── compute
│   │       │   ├── databases
│   │       │   │   └── databases
│   │       │   ├── network
│   │       │   │   └── network
│   │       │   ├── region.hcl
│   │       │   ├── secrets
│   │       │   │   └── secrets
│   │       │   └── storage
│   │       │       └── storage
│   │       └── us-west-1
│   │           ├── compute
│   │           │   └── compute
│   │           ├── databases
│   │           │   └── databases
│   │           ├── network
│   │           │   └── network
│   │           ├── region.hcl
│   │           ├── secrets
│   │           │   └── secrets
│   │           └── storage
│   │               └── storage
│   └── stage
│       ├── env.hcl
│       └── stage-1
│           ├── us-east-1
│           │   ├── compute
│           │   │   └── compute
│           │   ├── databases
│           │   │   └── databases
│           │   ├── network
│           │   │   └── network
│           │   ├── region.hcl
│           │   ├── secrets
│           │   │   └── secrets
│           │   └── storage
│           │       └── storage
│           └── us-west-1
│               ├── compute
│               │   └── compute
│               ├── databases
│               │   └── databases
│               ├── network
│               │   └── network
│               ├── region.hcl
│               ├── secrets
│               │   └── secrets
│               └── storage
│                   └── storage
└── infrastructure.hcl

44 directories, 41 files
```

## Inheritance
The folder structure is designed to inherit configurations from the parent folders. For example, the `compute_commons.hcl` file in the `dev-1` folder inherits configurations from the `compute_commons.hcl` file in the `dev` folder, which in turn inherits configurations from the `environment_commons.hcl` file in the `dev` folder, and so on.

## Contributing
If you want to contribute to this repository, please create a pull request with your changes.

## License
This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

