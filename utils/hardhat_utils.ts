import { network } from "hardhat";

export async function disableLogging() {
  if (network.name === "hardhat") {
    await network.provider.send("hardhat_setLoggingEnabled", [false]);
  }
}
