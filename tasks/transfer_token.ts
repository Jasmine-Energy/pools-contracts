
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';
import { colouredLog, Contracts } from '@/utils';
import { IERC1155Upgradeable__factory } from '@/typechain';


task('transfer', 'Transfers an EAT')
    .addPositionalParam<string>('recipient', 'The account to receive token')
    .addParam<string>('token', 'Token ID to transfer')
    .addParam<string>('quantity', 'Number of tokens to transfer', '1')
    .addOptionalParam<string>('sender', 'Account to transfer token from. Default is ether\'s default signer')
    .addOptionalParam<string>('contract', 'Address of ERC-1155 contract to interact with')
    .addOptionalParam<string>('data', 'Optional data to include in transfer call')
    .setAction(
        async (
            taskArgs: TaskArguments,
            { ethers, getNamedAccounts, }: HardhatRuntimeEnvironment
        ): Promise<void> => {
            
            // 1. Load required accounts, contracts and info
            const { eat } = await getNamedAccounts();
            const sender = taskArgs.sender ?
                await ethers.getSigner(taskArgs.sender) : 
                (await ethers.getSigners())[0];
            const contractAddress = taskArgs.contract ?? eat;
            const { recipient, data } = taskArgs;
            const tokenId = parseInt(taskArgs.token);
            const quantity = parseInt(taskArgs.quantity);
            const contract = IERC1155Upgradeable__factory.connect(contractAddress, sender);

            // 2. Verify ownership of token
            const tokenBalance = await contract.balanceOf(sender.address, tokenId);
            if (tokenBalance.lt(quantity)) {
                colouredLog.red(
                    `Error: Insufficient balance. Sender (${sender.address}) has ${tokenBalance.toString()} of ${tokenId}`
                );
                return;
            }

            // 3. Initiate transfer
            const sendTx = await contract.safeTransferFrom(
                sender.address,
                recipient,
                tokenId,
                quantity,
                data
            );
            await sendTx.wait();

            colouredLog.blue(
                `Sent ${quantity} of token ID ${tokenId} to ${recipient} from ${sender.address} in Tx: ${sendTx.hash}`
            );
        }
    );
