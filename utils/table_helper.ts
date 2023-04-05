import { ethers } from "ethers";
import { HardhatRuntimeEnvironment, RunTaskFunction } from "hardhat/types";

interface LinkedTableCellOptions {
  explorerUrl?: string; // NOTE: explorerUrl must include a trailing "/"
  hre?: HardhatRuntimeEnvironment;
  run?: RunTaskFunction;
}

/**
 * @dev Used to wrap an input in an explorer URL in cli-table3
 * 
 * @param input Address or Tx to wrap in link
 * @param options Either an explorer URL, hardhat runtime, or Hardhat
 *                `run` function used to get explorer endpoint.
 * 
 * @returns A cli-table3 compliant entry which wraps input in an explorer
 *          link if possible or returns the input
 */
export async function makeLinkedTableCell(
  input: string,
  options: LinkedTableCellOptions
) {
  let explorerUrl: string;

  if (options.explorerUrl) {
    explorerUrl = options.explorerUrl;
  } else if (options.hre || options.run) {
    try {
      const explorerResult = await (options.hre
        ? options.hre.run("verify:get-etherscan-endpoint")
        : options.run!("verify:get-etherscan-endpoint"));

      explorerUrl = explorerResult.url.browserURL;
    } catch {
      return input;
    }
  } else {
    return input;
  }

  // If address
  if (ethers.utils.isAddress(input)) {
    return {
      content: input,
      href: `${explorerUrl}address/${input}`,
    };
    // If tx
  } else if (input.length == (input.startsWith("0x") ? 66 : 64)) {
    return {
      content: input,
      href: `${explorerUrl}tx/${input}`,
    };
  }
  return input;
}
