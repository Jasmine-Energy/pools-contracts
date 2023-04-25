# Jasmine Reference Pools

[![test](https://github.com/Jasmine-Energy/v1-pools-contracts/actions/workflows/test.yml/badge.svg)](https://github.com/Jasmine-Energy/v1-pools-contracts/actions/workflows/test.yml)
[![GitBook - Documentation](https://img.shields.io/badge/GitBook-Documentation-orange?logo=gitbook&logoColor=white)](https://docs.jasmine.energy/)
[![Chat](https://img.shields.io/discord/1012757430779789403)](https://discord.gg/bcGUebezJb)
[![License: BUSL 1.1](https://img.shields.io/badge/License-BUSL%201.1-blue.svg)](./LICENSE)
[![built-with openzeppelin](https://img.shields.io/badge/built%20with-OpenZeppelin-3677FF)](https://docs.openzeppelin.com/)
[![hardhat](https://hardhat.org/buidler-plugin-badge.svg)](https://hardhat.org)

This repository contains the smart contracts for Jasmine's Reference Pools. Reference pools enable Energy Attribution Token (EAT) holders to deposit their ERC-1155 tokens into specific pools with deposit criteria. Depositers are issued an [ERC-777](https://eips.ethereum.org/EIPS/eip-777) and [ERC-20](https://eips.ethereum.org/EIPS/eip-20) compliant token that can be used across the Defi ecosystem.

# Contents
- [Contracts Overview](#contracts-overview)
- [Local Development](#local-development)
- [License](#license)

# Contracts Overview
Jasmine Reference Pool's are supported by 3 primary contracts:
- [Pool Factory](#jasmine-pool-factory)
- [Pool and Base Pool](#jasmine-pools)
- [Retirement Service](#jasmine-retirement-service)

## **Pool Factory**
- [Interface](./contracts/interfaces/IJasminePoolFactory.sol)
- [Source](./contracts/JasminePoolFactory.sol)
- [Docs](./docs/JasminePoolFactory.md)

The *Jasmine Pool Factory* is responsible for managing the deployment of new pools, adding new pool implementations and managing shared permissions across the protocol. It is a non-upgradeable contract which implements [`Ownable2Step`](https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable2Step) and [`AccessControl`](https://docs.openzeppelin.com/contracts/4.x/api/access#AccessControl) for managing `FEE_MANAGER_ROLE` permissions.

**1. Pool Deployment**

The *Pool Factory* supports multiple pool implementations to allow Jasmine to release different versions of pools for different use cases. The *Pool Factory*'s owner is able to add new pool implementations via the `addPoolImplementation` function. To add a new pool implementation, the address must support ERC-165 and declare its implementation of the *Jasmine Pool Interface* - defined in [`IJasminePool`](./contracts/interfaces/IJasminePool.sol). Pool implementations must be unique. When new pool implementations are added, a `PoolImplementationAdded` event and will be assigned a version number - which is its index in the set of pool implementations.

Once a pool implementation is added to the factory's list of implementations, the owner is able to deploy a new pool deterministically (via `CREATE2`) which is derived from the hash of the `Deposit Policy`. Deploying a new pool from the factory results in an [ERC-1967 proxy](https://docs.openzeppelin.com/contracts/4.x/api/proxy#ERC1967Proxy) being deployed with its implementation address set to the approved predeployed pool implementation stored in the factory.

There exists two methods for the owner to deploy a new pool from the factory: `deployNewPool` and `deployNewBasePool`. Deploy base pool is a convenience abstraction on top of the general purpose `deployNewPool` which takes in a `DepositPolicy` struct (see [`PoolPolicy` library](./contracts/libraries/PoolPolicy.sol)), a token name and a token symbol. It then correctly encodes the `DepositPolict`, designates the initializer selector and relays the deployment instruction to `deployNewPool`. 

**NOTES:**
- A pool implementation's initializer expects the final two arguments to be `name_` and `symbol_`
- The *Pool Factory* will eventually be the ERC-1967's admin entity, allowing the pool factory to upgrade pool implementations for deployed pools. This is not yet supported

**2. Access Control**

The *Pool Factory* is also the central location where access control permissions are stored across the protocol. Pool's implementing the [`JasmineFeePool`](./contracts/pools/extensions/JasmineFeePool.sol) extension, for instance, defer to the *Pool Facotry* to determine who is an authorize fee manager privy to change the withdrawal and retirement fee for the pool. Currently, the `DEFAULT_ADMIN_ROLE` - which is the role admin of `FEE_MANAGER_ROLE` - tracks the owner of the contract, giving the owner the exclusive authority to grant and revoke roles.

**3. Shared State**

Lastly, the *Pool Factory* is responsible for storing shared state across the protocol which pools may depend upon. [`JasmineFeePool`](./contracts/pools/extensions/JasmineFeePool.sol) defers to the factory to get its base withdrawal and retirement fees if no specific values are provided for the pool. 

**NOTES:**


## **Reference Pools**
- [Interface](./contracts/interfaces/IJasminePool.sol)
- [Source](./contracts/JasminePool.sol)
- [Docs](./docs/JasminePool.md)

*Jasmine Reference Pools* are contracts which are able to receive *Energy Attribute Tokens* (EATs) as deposits and issue pool specific *Jasmine Liquidity Tokens* (JLTs) in exchange. JLT holders are able to withdraw EATs from the issuing pool by burning their JLTs - and may also retire JLTs directly.

*Jasmine Reference Pools* implement [ERC-777](https://docs.openzeppelin.com/contracts/4.x/api/token/erc777) (which extends [ERC-20](https://eips.ethereum.org/EIPS/eip-20)) as well as the [ERC-2612 Permit Extension](https://eips.ethereum.org/EIPS/eip-2612), [ERC-1046 TokenURI Interoperability](https://eips.ethereum.org/EIPS/eip-1046) and [ERC-1363 Payable Token](https://eips.ethereum.org/EIPS/eip-1363) standards.

### **Reference Pools Design Pattern**

#### **1. Jasmine Base Pool**

*Jasmine Reference Pools* are deliberately designed to be extensible and modular allowing the creation of pools which suit any need. All pools are intended to inherit from the abstract [`JasmineBasePool` contract](./contracts/pools/core/JasmineBasePool.sol) which implements the core functionality of a pool (as defined in the [`IJasminePool`](./contracts//interfaces/IJasminePool.sol) interface). 

[Pool extensions](#2-pool-extensions) and [instantiations](#3-pool-instantiations) both override and extend the base pool to fit their needs, but can lean on the base implementation to minimize code duplication and to enable easier inheritence linearization. 

The *Jasmine Base Pool* implements deposit functionality contidional upon `meetsPolicy` passing - which is expected to be overriden by [*extensions*](#2-pool-extensions) and [*instantiations*](#3-pool-instantiations) contracts to create more restrictive deposit criteria. The *Base Pool*'s only deposit criteria is that a token (1) is an EAT, (2) is not frozen and (3) exists.

The *Jasmine Base Pool* also impements withdrawal and retirement functionality which is costed per the `withdrawalCost` function. 

**NOTE:**
- `IJasminePool` interface is deliberately unimplemented by base pool at present time and will be readded once code is in more stable state
- Pool are in active development: the above is subject to change
 
#### **2. Pool Extensions**

*Pool Extensions* are abstract contracts, defined in [`contracts/pools/extensions`](./contracts/pools/extensions/), which add additional functionality to on top of the *Base Pool*. Currently, `JasmineFeePool` is the only extension, though, more will follow and functionality from later pools may be generalized into an extension as needed.

This design pattern is inspired by Openzeppelin's modular approach and composable approach to smart contract development.

#### **3. Pool Instantiations**

*Pool Instantiations* are the real-world smart contracts deployed to be used as implementations within the factory. Currently, only one instantiation exists: the [`JasminePool`](./contracts/JasminePool.sol). 

**The Jasmine Pool**

The *Jasmine Pool* inherits from the *Base Pool* which implements the `JasmineFeePool` extension. The *Jasmine Pool* uses the [`PoolPolicy`](./contracts/libraries/PoolPolicy.sol) library's `DepositPolicy` to restrict which EATs may be deposited. 

The [`PoolPolicy`](./contracts/libraries/PoolPolicy.sol) library defines the different *Deposit Policies* (currently, only one simple policy is supported) pool's may have and creates utility functions for validating eligibility, and (coming soon) comparing like policies to determine inter-pool transfer requirements (ie. if Pool A's policy is a subset of Pool B's policy, JLTs may be transferred from Pool A to Pool B without verifying the eligibility of the EATs Pool B will withdraw upon receipt of Pool A's JLTs).

## **Jasmine Retirement Service**
- [Interface](./contracts/interfaces/IRetirementService.sol)
- [Source](./contracts/JasmineRetirementService.sol)
- [Docs](./docs/JasmineRetirementService.md)

**TODO**

## Full Documentation
For full documentation about the Jasmine Reference Pool contracts, [view docs](./docs/) or visit our [GitBook](https://docs.jasmine.energy/).

# Useage

## Local Development
This repository uses [Hardhat](https://hardhat.org/) as its IDE and makes extensive use of [OpenZeppelin's core contract](https://docs.openzeppelin.com/contracts/4.x/) (v4.8.2). The project also makes extensive use of [Tenderly](https://tenderly.co/), though, it is not required to run locally.

## Setup
Be sure to set either an `INUFRA_API_KEY` in .env or specify RPC URLs in .env. To make use of Tenderly (such as the fork management and account funding [hardhat tasks](./tasks/tenderly/)) set `TENDERLY_API_KEY`.

## Installation
To install dependencies, run `npm install`

**NOTE:** currently, you will require a [Github personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) set in order to access the core contracts repo. Get one [here](https://github.com/settings/tokens).

## Testing

To run all unit tests in [`test`](./test/), simply run `npm run test`. 

## Deploying

To deploy contracts locally, run `npm run start`. This will deploy core contract, librariies, Jasmine Pool implementation contract and the Jasmine Pool Factory. From there, you can run `npx hardhat mint ADDRESS` to mint testing EATs. 

## Utility Tasks

1. **Minting EATs**: `npx hardhat mint ADDRESS` Default network is localhost (aka running hardhat chain)
2. **Listing Pools**: `npx hardhat pool:list`
3. **Get Pool from Factory**: `npx hardhat pool:at` Get address of a pool from deployment index
4. **Transfer 1155**: `npx hardhat transfer` Convenience utility to transfer EATs. *Tip:* EATs may be depositted into a pool via an 1155 transfer

## Linting

The project uses both ESLint and Solhint. To run linter, use `npm run lint` or `npm run lint:fix` to lint and fix where possible.

# Additional Info

## Licenses
Jasmine Reference Pool contracts are licensed under the Business Source License 1.1 (`BUSL-1.1`), see [LICENSE](./LICENSE). However, all contract interfaces, located in [`/contracts/interfaces`](./contracts/interfaces), are MIT licensed, see [MIT license](./contracts/interfaces/LICENSE).
