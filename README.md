<p align="center" width="100%">
    <a href="https://www.develeap.com/">
    <img src="https://github.com/develeap/iac-terragrunt-template/raw/feature/digger/docs/media/icon.png" alt="Develeap - we can take you there!" width="500" height="500">
    </a>
</p>

[1]: https://www.develeap.com/

## Introduction

This repository is a template to be used for future terragrunt projects. It contains a basic structure for terragrunt projects and some basic modules to be used as examples.

## Table of Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Cheat Sheet](docs/CheatSheet.md)
- [Usage](#usage)
- [Build the infrastructure folder structure](#build-the-infrastructure-folder-structure)
- [Example](#example)
- [Inheritance](#inheritance)
- [Documentation](#documentation)
  - [Local vs Pipeline Architencture](docs/local-vs-pipeline-assume-role-diagram.md)
  - [Include Deep Dive](docs/include-deepdive.md)
- [Contributing](#contributing)
- [License](#license)

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

Make sure to check the [Cheat Sheet](docs/CheatSheet.md) for some useful commands and tips.

## Usage

Use the Justfile provided in this repository to run various commands. You can see the available commands by running `just --list`.
[![asciicast](https://asciinema.org/a/oy1cKWQRrgs5EUZDDvaOZBc2E.svg)](https://asciinema.org/a/oy1cKWQRrgs5EUZDDvaOZBc2E)

### Build the infrastructure folder structure

To build the infrastructure folder structure, run the following command:
_Make sure to set the desired account-ids, regions, environments in [build-folder-structure script](/scripts/build-folder-structure.sh)_

```bash
just build-folder-structure
```

#### Example:

```bash
infrastructure-live
├── 01234567890
│   ├── account.hcl
│   ├── dev
│   │   ├── dev-1
│   │   │   └── il-central-1
│   │   │       ├── compute
│   │   │       │   └── compute.hcl
│   │   │       ├── database
│   │   │       │   └── database.hcl
│   │   │       ├── network
│   │   │       │   └── network.hcl
│   │   │       ├── region.hcl
│   │   │       ├── secret
│   │   │       │   └── secret.hcl
│   │   │       └── storage
│   │   │           └── storage.hcl
│   │   └── env.hcl
│   ├── prod
│   │   ├── env.hcl
│   │   └── prod-1
│   │       └── il-central-1
│   │           ├── compute
│   │           │   ├── compute.hcl
│   │           │   └── demo-ec2
│   │           │       └── terragrunt.hcl
│   │           ├── database
│   │           │   └── database.hcl
│   │           ├── network
│   │           │   └── network.hcl
│   │           ├── region.hcl
│   │           ├── secret
│   │           │   └── secret.hcl
│   │           └── storage
│   │               └── storage.hcl
│   ├── provider.hcl
│   └── stage
│       ├── env.hcl
│       └── stage-1
│           └── il-central-1
│               ├── compute
│               │   └── compute.hcl
│               ├── database
│               │   └── database.hcl
│               ├── network
│               │   └── network.hcl
│               ├── region.hcl
│               ├── secret
|               │   └── secret.hcl
│               └── storage
│                   └── storage.hcl
└── infrastructure.hcl

27 directories, 25 files
```

## Inheritance

The folder structure is designed to allow for inheritance of configurations. The `account.hcl` file is used to define the account specific configurations, while the `env.hcl` file is used to define the environment specific configurations. The `region.hcl` file is used to define the region specific configurations. And so forth.
A single include block will be used to include all the configurations from the parent folders.

## Documentation

Additional documentation can be found in the [docs](docs) folder.

## Contributing

If you want to contribute to this repository, please create a pull request with your changes.

## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
