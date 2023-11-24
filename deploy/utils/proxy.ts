import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { ethers } from "ethers";
import { BaseContract } from "ethers";
import { FunctionFragment } from "@ethersproject/abi";

interface Initializer {
  functionName: string | FunctionFragment;
  args: any[];
}

export const proxyBytecode =
  "0x603960156a3d3d3d3d363d3d37363d7f3d7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc60146079600c393d518082553d3d608d80380380913d393d845af46053578280fd5b3d605f573b6061575080fd5b505b6d545af43d3d93803e603757fd5bf3602e5260205252f3";

export async function deployProxy(
  impl: BaseContract,
  initializer: Initializer,
  signer: SignerWithAddress,
  waitConfirmations: number = 1
) {
  const initializerInterface = new ethers.utils.Interface([
    initializer.functionName,
  ]);

  const initEncodedCall = initializerInterface.encodeFunctionData(
    initializer.functionName,
    initializer.args
  );

  const initCode = ethers.utils.solidityPack(
    ["bytes", "address", "bytes"],
    [proxyBytecode, impl.address, initEncodedCall]
  );

  const tx = await signer.sendTransaction({
    data: initCode,
  });
  const receipt = await tx.wait(waitConfirmations);

  return {
    contract: impl.attach(receipt.contractAddress),
    tx,
    receipt,
    constructorArgs: [impl.address, initEncodedCall],
  };
}
