import { forkNetworkName } from "./networks";
import { makeNamedAccounts } from "./accounts";

export const namedAccounts = makeNamedAccounts(
  forkNetworkName as "polygon" | "mumbai"
);

export * from "./networks";
export * from "./accounts";
export * from "./solidity";
export * from "./extensions";
