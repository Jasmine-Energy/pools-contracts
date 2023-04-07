import { JsonRpcProvider } from "@ethersproject/providers";
import { Tenderly, TenderlyEndpoints } from "./constants";
import axios, { AxiosResponse } from "axios";
import * as dotenv from "dotenv";
import { Signer } from "ethers";

dotenv.config();

// describes forking request. network_id is the only required attribute, 
// but feel free to override any
export type TenderlyFork = {
    block_number?: number;
    network_id: string;
    initial_balance?: number;
    chain_config?: {
        chain_id: number;
    };
};

// All you need to access the forked environment from your tests
export type EthersOnTenderlyFork = {
    provider: JsonRpcProvider;
    /** test accounts: map from address to given address' balance */
    accounts: { [key: string]: string };
    /** test accounts: signers for transactions*/
    signers: Signer[],
    /** a function to remove fork from Tenderly infrastructure, meant for test clean-up */
    removeFork: () => Promise<AxiosResponse<any, any>>;
};

export const anAxiosOnTenderly = () => axios.create({
    baseURL: Tenderly.apiBaseUrl,
    headers: {
        "X-Access-Key": process.env.TENDERLY_API_KEY || "",
        "Content-Type": "application/json",
    },
});
/**
    Create a fork on Tenderly with parameters declared through the 
    fork parameter.
*/
export const forkForTest = async (fork: TenderlyFork): Promise<EthersOnTenderlyFork> => {
    const axiosOnTenderly = anAxiosOnTenderly();

    const forkResponse = await axiosOnTenderly.post(Tenderly.endpoints(TenderlyEndpoints.fork), fork);
    const forkId = forkResponse.data.root_transaction.fork_id;
    console.info("Forked with fork id:", forkId)
    const provider = new JsonRpcProvider(`https://rpc.tenderly.co/fork/${forkId}`);

    const accounts = forkResponse.data.simulation_fork.accounts;

    const signers = Object.keys(accounts)
        .map(address => provider.getSigner(address));
    console.log("Accounts on fork", accounts)

    return {
        provider,
        accounts,
        signers,
        removeFork: async () => {
            console.log("Removing test fork", forkId);
            return await axiosOnTenderly.delete(
                `${Tenderly.endpoints(TenderlyEndpoints.fork)}/${forkId}`
              );
        },
    };
};
