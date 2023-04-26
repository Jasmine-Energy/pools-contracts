import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts } from "@/utils";
import { JasminePoolFactory } from "@/typechain";
import * as Permit2 from "@uniswap/permit2-sdk";
import { Interface } from "@ethersproject/abi";

task("permit:transfer", "Transfers using permit2")
  .addPositionalParam<string>("signature", "Permit signature of transfer")
  .addPositionalParam<string>("amount", "Number of JLTs to permit", "1")
  .addPositionalParam<string>("pool", "Pool address or index", "0")
  .addOptionalParam<string>("spender", "The account's address")
  .setAction(
    async (
      taskArgs: TaskArguments,
      {
        ethers,
        deployments,
        hardhatArguments,
      }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      let poolAddress: string;
      if (taskArgs.pool.length === 42) {
        poolAddress = taskArgs.pool;
      } else {
        const poolFactoryDeployment = await deployments.get(Contracts.factory);
        const poolFactory = (await ethers.getContractAt(
          Contracts.factory,
          poolFactoryDeployment.address
        )) as JasminePoolFactory;
        poolAddress = await poolFactory.getPoolAtIndex(parseInt(taskArgs.pool));
      }
      // TODO: attach signer
      const signer = taskArgs.spender ? await ethers.getSigner(taskArgs.spender) : (await ethers.getSigners())[0];
      const chainId = await signer.getChainId();

      const amount = BigInt(parseInt(taskArgs.amount)) * (10n ** 18n);
      const expiration = "0";
      const nonce = 0;
    
      const permit = Permit2.AllowanceTransfer.getPermitData(
        {
          details: [
            {
              token: poolAddress,
              amount,
              expiration,
              nonce,
            },
          ],
          spender: signer.address,
          sigDeadline: "0",
        },
        Permit2.PERMIT2_ADDRESS,
        chainId
      );

      const signature = await signer._signTypedData(permit.domain, permit.types, permit.values);

      if (hardhatArguments.verbose) {
        colouredLog.yellow("Permit typed data: ");
        console.log(permit);
      }

      colouredLog.blue(`Permit is: ${signature}`)

      
      const permit2ABI = new Interface(
        [{"inputs":[{"internalType":"uint256","name":"deadline","type":"uint256"}],"name":"AllowanceExpired","type":"error"},{"inputs":[],"name":"ExcessiveInvalidation","type":"error"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"InsufficientAllowance","type":"error"},{"inputs":[{"internalType":"uint256","name":"maxAmount","type":"uint256"}],"name":"InvalidAmount","type":"error"},{"inputs":[],"name":"InvalidContractSignature","type":"error"},{"inputs":[],"name":"InvalidNonce","type":"error"},{"inputs":[],"name":"InvalidSignature","type":"error"},{"inputs":[],"name":"InvalidSignatureLength","type":"error"},{"inputs":[],"name":"InvalidSigner","type":"error"},{"inputs":[],"name":"LengthMismatch","type":"error"},{"inputs":[{"internalType":"uint256","name":"signatureDeadline","type":"uint256"}],"name":"SignatureExpired","type":"error"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"token","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint160","name":"amount","type":"uint160"},{"indexed":false,"internalType":"uint48","name":"expiration","type":"uint48"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"address","name":"token","type":"address"},{"indexed":false,"internalType":"address","name":"spender","type":"address"}],"name":"Lockdown","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"token","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint48","name":"newNonce","type":"uint48"},{"indexed":false,"internalType":"uint48","name":"oldNonce","type":"uint48"}],"name":"NonceInvalidation","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"token","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint160","name":"amount","type":"uint160"},{"indexed":false,"internalType":"uint48","name":"expiration","type":"uint48"},{"indexed":false,"internalType":"uint48","name":"nonce","type":"uint48"}],"name":"Permit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":false,"internalType":"uint256","name":"word","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"mask","type":"uint256"}],"name":"UnorderedNonceInvalidation","type":"event"},{"inputs":[],"name":"DOMAIN_SEPARATOR","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint160","name":"amount","type":"uint160"},{"internalType":"uint48","name":"expiration","type":"uint48"},{"internalType":"uint48","name":"nonce","type":"uint48"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint160","name":"amount","type":"uint160"},{"internalType":"uint48","name":"expiration","type":"uint48"}],"name":"approve","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint48","name":"newNonce","type":"uint48"}],"name":"invalidateNonces","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"wordPos","type":"uint256"},{"internalType":"uint256","name":"mask","type":"uint256"}],"name":"invalidateUnorderedNonces","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"internalType":"struct IAllowanceTransfer.TokenSpenderPair[]","name":"approvals","type":"tuple[]"}],"name":"lockdown","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint256","name":"","type":"uint256"}],"name":"nonceBitmap","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"components":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint160","name":"amount","type":"uint160"},{"internalType":"uint48","name":"expiration","type":"uint48"},{"internalType":"uint48","name":"nonce","type":"uint48"}],"internalType":"struct IAllowanceTransfer.PermitDetails[]","name":"details","type":"tuple[]"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"sigDeadline","type":"uint256"}],"internalType":"struct IAllowanceTransfer.PermitBatch","name":"permitBatch","type":"tuple"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"permit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"components":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint160","name":"amount","type":"uint160"},{"internalType":"uint48","name":"expiration","type":"uint48"},{"internalType":"uint48","name":"nonce","type":"uint48"}],"internalType":"struct IAllowanceTransfer.PermitDetails","name":"details","type":"tuple"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"sigDeadline","type":"uint256"}],"internalType":"struct IAllowanceTransfer.PermitSingle","name":"permitSingle","type":"tuple"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"permit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"internalType":"struct ISignatureTransfer.TokenPermissions","name":"permitted","type":"tuple"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct ISignatureTransfer.PermitTransferFrom","name":"permit","type":"tuple"},{"components":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"requestedAmount","type":"uint256"}],"internalType":"struct ISignatureTransfer.SignatureTransferDetails","name":"transferDetails","type":"tuple"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"permitTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"internalType":"struct ISignatureTransfer.TokenPermissions[]","name":"permitted","type":"tuple[]"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct ISignatureTransfer.PermitBatchTransferFrom","name":"permit","type":"tuple"},{"components":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"requestedAmount","type":"uint256"}],"internalType":"struct ISignatureTransfer.SignatureTransferDetails[]","name":"transferDetails","type":"tuple[]"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"permitTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"internalType":"struct ISignatureTransfer.TokenPermissions","name":"permitted","type":"tuple"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct ISignatureTransfer.PermitTransferFrom","name":"permit","type":"tuple"},{"components":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"requestedAmount","type":"uint256"}],"internalType":"struct ISignatureTransfer.SignatureTransferDetails","name":"transferDetails","type":"tuple"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"bytes32","name":"witness","type":"bytes32"},{"internalType":"string","name":"witnessTypeString","type":"string"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"permitWitnessTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"internalType":"struct ISignatureTransfer.TokenPermissions[]","name":"permitted","type":"tuple[]"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"}],"internalType":"struct ISignatureTransfer.PermitBatchTransferFrom","name":"permit","type":"tuple"},{"components":[{"internalType":"address","name":"to","type":"address"},{"internalType":"uint256","name":"requestedAmount","type":"uint256"}],"internalType":"struct ISignatureTransfer.SignatureTransferDetails[]","name":"transferDetails","type":"tuple[]"},{"internalType":"address","name":"owner","type":"address"},{"internalType":"bytes32","name":"witness","type":"bytes32"},{"internalType":"string","name":"witnessTypeString","type":"string"},{"internalType":"bytes","name":"signature","type":"bytes"}],"name":"permitWitnessTransferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint160","name":"amount","type":"uint160"},{"internalType":"address","name":"token","type":"address"}],"internalType":"struct IAllowanceTransfer.AllowanceTransferDetails[]","name":"transferDetails","type":"tuple[]"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"from","type":"address"},{"internalType":"address","name":"to","type":"address"},{"internalType":"uint160","name":"amount","type":"uint160"},{"internalType":"address","name":"token","type":"address"}],"name":"transferFrom","outputs":[],"stateMutability":"nonpayable","type":"function"}]
      );
      const permit2Contract = new ethers.Contract(Permit2.PERMIT2_ADDRESS, permit2ABI, signer);
      console.log(111)
    //   console.log(await permit2Contract["allowance"](poolAddress, signer.address, "0x4072ff0d59436ce70a63eaadfd32a2240603fc14"))
    console.log(permit2Contract, poolAddress)
    const coder = new ethers.utils.AbiCoder

      const tx = await permit2Contract["permitTransferFrom(((address,uint256),uint256,uint256),(address,uint256),address,bytes)"](coder.encode(["address","uint256","uint256","uint256"],[poolAddress,amount,expiration,nonce]), coder.encode(["address","uint256"], ["0x4072ff0d59436ce70a63eaadfd32a2240603fc14", amount]), signer.address, signature);
      console.log(tx)
    }
  );
