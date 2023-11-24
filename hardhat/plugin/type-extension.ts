import "hardhat/types/config";
import "hardhat/types/runtime";

// import { ExampleHardhatRuntimeEnvironmentField } from "./ExampleHardhatRuntimeEnvironmentField";

declare module "hardhat/types/config" {}

declare module "hardhat/types/runtime" {
  export interface HardhatRuntimeEnvironment {
    jasmine: {
      deployPools: () => Promise<void>;
      Constants: {
        [key: string]: string;
      };
    };
  }
}
