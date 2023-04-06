import { colouredLog } from '@/utils';
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';
import * as forksFile from '../../tenderly-forks.json';
import fs from 'fs/promises';
import axios from 'axios';
import path from 'path';


const TENDERLY_FORK_API = `http://api.tenderly.co/api/v1/account/Jasmine/project/reference-pools/fork`;

task("fork", "Creates a tenderly fork of network")
  .addOptionalParam<string>("name", "Optional name to save fork as")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId, ...hre }: HardhatRuntimeEnvironment
    ): Promise<void> => {
        const opts = {
            headers: {
                'X-Access-Key': process.env.TENDERLY_API_KEY,
            }
        }
        const chainId = await getChainId();
        const body = {
          "network_id": chainId,
        }
        
        
        
        const resp = await axios.post(TENDERLY_FORK_API, body, opts);

        if (resp.status != 201) {
            colouredLog.red("Failed");
            return;
        }

        const { simulation_fork } = resp.data;
        
        var updatesForks = forksFile;
        updatesForks.forks.push({
            name: taskArgs.name ?? `${network.name} Fork from ${new Date(simulation_fork.created_at).toString()}`,
            ...simulation_fork
        });

        await fs.writeFile(path.join(hre.config.paths.root, 'tenderly-forks.json'), JSON.stringify({
            total: updatesForks.forks.length,
            forks: updatesForks.forks
        }));
        
        colouredLog.blue(`Fork created! Index: ${updatesForks.total} ID: ${simulation_fork.id}`);
    }
  );
