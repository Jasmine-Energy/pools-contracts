import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { makeLinkedTableCell } from "@/utils/table_helper";
import Table from "cli-table3";

task("deployments", "List all contracts in deployments")
  .addFlag("proxy", "Include proxy implementation if deployed via ERC-1967")
  .addFlag("tx", "Include deployment transaction")
  .addFlag("args", "Include constructor args")
  .setAction(
    async (
      taskArgs: TaskArguments,
      {
        deployments,
        run,
      }: HardhatRuntimeEnvironment
    ) => {
      const deployed = await deployments.all();
      const deployedContracts = Object.entries(deployed);
      const head = ["Contract", "Address"];
      const colWidths = [20, 44];

      if (taskArgs.proxy) {
        head.push("Implementation Address");
        colWidths.push(44);
      }
      if (taskArgs.tx) {
        head.push("Transaction");
        colWidths.push(68);
      }
      if (taskArgs.args) {
        head.push("Constructor Args");
        colWidths.push(48);
      }

      var table = new Table({
        head,
        colWidths,
        style: {
          head: ["yellow"],
          border: [],
        },
        wordWrap: true,
        wrapOnWordBoundary: false,
      });

      for (var i = 0; i < deployedContracts.length; i++) {
        const [deploymentName, deployment] = [
          deployedContracts[i][0],
          deployedContracts[i][1],
        ];
        const row = [deploymentName, await makeLinkedTableCell(deployment.address, { run })];

        if (taskArgs.proxy) {
          row.push(
            deployment.implementation ? await makeLinkedTableCell(deployment.implementation, { run }) : "None"
          );
        }
        if (taskArgs.tx) {
          row.push(
            deployment.transactionHash ? await makeLinkedTableCell(deployment.transactionHash, { run }) : "None"
          );
        }
        if (taskArgs.args) {
          row.push(JSON.stringify(deployment.args) ?? "None");
        }
        table.push(row);
      }

      console.log(table.toString());
    }
  );
