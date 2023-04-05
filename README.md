# Jasmine Reference Pools

[![test](https://github.com/Jasmine-Energy/v1-pools-contracts/actions/workflows/test.yml/badge.svg)](https://github.com/Jasmine-Energy/v1-pools-contracts/actions/workflows/test.yml)
[![GitBook - Documentation](https://img.shields.io/badge/GitBook-Documentation-orange?logo=gitbook&logoColor=white)](https://docs.jasmine.energy/)
[![Chat](https://img.shields.io/discord/1012757430779789403)](https://discord.gg/bcGUebezJb)
[![License: BUSL 1.1](https://img.shields.io/badge/License-BUSL%201.1-blue.svg)](./LICENSE)
[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)
[![hardhat](https://hardhat.org/buidler-plugin-badge.svg)](https://hardhat.org)

This repository contains the smart contracts for Jasmine's Reference Pools. Reference pools enable Energy Attribution Token (EAT) holders to deposit their ERC-1155 tokens into specific pools with deposit criteria. Depositers are issued an [ERC-777](https://eips.ethereum.org/EIPS/eip-777) and [ERC-20](https://eips.ethereum.org/EIPS/eip-20) compliant token that can be used across the Defi ecosystem.

## Contents
- [Contracts Overview](#contracts-overview)
- [Local Development](#local-development)
- [License](#license)

## Contracts Overview

### Full Documentation
For full documentation about the Jasmine Reference Pool contracts, [view docs](./docs/) or visit our [GitBook](https://docs.jasmine.energy/).

## Local Development
This repository uses [Hardhat](https://hardhat.org/) as its IDE.

### Installation
To install dependencies, run `npm install`.

## Licenses
Jasmine Reference Pool contracts are licensed under the Business Source License 1.1 (`BUSL-1.1`), see [LICENSE](./LICENSE). However, all contract interfaces, located in [`/contracts/interfaces`](./contracts/interfaces), are MIT licensed, see [MIT license](./contracts/interfaces/LICENSE).
