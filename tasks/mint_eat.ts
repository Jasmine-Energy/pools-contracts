import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import {
  FuelType,
  CertificateRegistry,
  EnergyCertificateType,
  CertificateEndorsement,
  FuelTypesArray,
  CertificateRegistryArr,
  CertificateArr,
  CertificateEndorsementArr,
} from "@/types/energy-certificate.types";
import {
  encodeEnergyAttributeTokenId,
  encodeOracleData,
} from "@/utils/token_encoding";

task("mint", "Mints an EAT")
  .addOptionalPositionalParam<string>("account", "The account's address")
  .addParam<string>(
    "vintage",
    "EAT's vintage in form YYYY-MM-DD.",
    new Date().toISOString().split("T")[0]
  )
  .addParam<FuelType>(
    "fuel",
    `EAT's fuel type. Either ${FuelTypesArray.join(", ")}.`,
    FuelType.SOLAR
  )
  .addParam<CertificateRegistry>(
    "registry",
    `EAT's registry. Either ${CertificateRegistryArr.join(", ")}.`,
    CertificateRegistry.NAR
  )
  .addParam<EnergyCertificateType>(
    "certificateType",
    `EAT certificateTypes. Either ${CertificateArr.join(", ")}`,
    EnergyCertificateType.REC
  )
  .addParam<CertificateEndorsement>(
    "endorsement",
    `EAT endorsements. Either ${CertificateEndorsementArr.join(", ")}`,
    CertificateEndorsement.GREEN_E
  )
  .addParam<string>("quantity", "Number of EATs to mint.", "5")
  .addOptionalParam("minter", "Address of minter contract")
  .addOptionalParam("uuid", "Specifiy the uuid of the associated certificate")
  .setAction(
    async (
      taskArgs: TaskArguments,
      {
        ethers,
        deployments,
        network,
        getNamedAccounts,
        run,
        hardhatArguments,
      }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      if (network.tags["production"]) {
        colouredLog.red("Error: Unable to use mint on production network.");
        return;
      }
      // 1. Check if typechain exists. If not, compile and explicitly generate typings
      if (!tryRequire("@/typechain")) {
        await run("compile");
        await run("typechain");
      }
      // @ts-ignore
      const { JasmineMinter__factory } =
        await import("@/typechain");

      // 1. Load required accounts, contracts and info
      const { bridge, minter } = await getNamedAccounts();
      let minterSavedAddress;
      try {
        minterSavedAddress = (await deployments.get(Contracts.minter)).address;
      } catch {
        minterSavedAddress = minter;
      }
      const minterAddress = taskArgs.minter ?? minterSavedAddress;
      const signer = taskArgs.account
        ? await ethers.getSigner(taskArgs.account)
        : (await ethers.getSigners())[0];
      const recipientAddress: string = signer.address;
      const minterContract = JasmineMinter__factory.connect(minterAddress, signer);
      const bridgeSigner = await ethers.getSigner(bridge);
      const chainId = await bridgeSigner.getChainId();

      // 2. Create typed data struct
      const domain = {
        name: Contracts.minter,
        version: "1",
        chainId: chainId,
        verifyingContract: minterAddress.toLowerCase(),
      };
      const types = {
        MintAuthorization: [
          { name: "minter", type: "address" },
          { name: "id", type: "uint256" },
          { name: "amount", type: "uint256" },
          { name: "oracleData", type: "bytes" },
          { name: "deadline", type: "uint256" },
          { name: "nonce", type: "bytes32" },
        ],
      };
      const uuidPacked = ethers.utils
        .hexZeroPad(ethers.utils.hexValue(ethers.utils.randomBytes(16)), 16)
        .slice(2);
      const uuid = taskArgs.uuid ? taskArgs.uuid : [
        uuidPacked.slice(0, 8),
        uuidPacked.slice(8, 12),
        uuidPacked.slice(12, 16),
        uuidPacked.slice(16, 20),
        uuidPacked.slice(20),
      ].join("-");

      const id = encodeEnergyAttributeTokenId(
        uuid,
        taskArgs.registry,
        new Date(taskArgs.vintage)
      );
      const amount = parseInt(taskArgs.quantity);

      const oracleData = encodeOracleData(
        uuid,
        taskArgs.registry,
        new Date(taskArgs.vintage),
        taskArgs.fuel,
        taskArgs.certificateType,
        taskArgs.endorsement
      );

      const deadline = Math.ceil(new Date().getTime() / 1_000) + 86_400; // 1 day
      const nonce = ethers.utils.randomBytes(32);
      const value = {
        minter: recipientAddress,
        id,
        amount,
        oracleData,
        deadline,
        nonce,
      };
      const signature = await bridgeSigner._signTypedData(domain, types, value);

      const tx = await minterContract.mint(
        recipientAddress,
        id,
        amount,
        [],
        oracleData,
        deadline,
        nonce,
        signature
      );

      const result = await tx.wait();

      colouredLog.blue(
        `Minted ${amount} tokens of ID ${id} to ${recipientAddress}. Tx: ${tx.hash}`
      );

      if (hardhatArguments.verbose) {
        console.log("Result: ", result);
      }
    }
  );
