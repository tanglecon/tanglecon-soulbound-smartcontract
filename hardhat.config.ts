import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";
import "@nomicfoundation/hardhat-network-helpers";

import deployer from "./utils/env/deployer";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    'shimmerevm-testnet': {
      url: 'https://json-rpc.evm.testnet.shimmer.network',
      chainId: 1071,
      accounts: [deployer.privateKey],
    },
  },
  etherscan: {
    apiKey: {
      'shimmerevm-testnet': 'ABCDE12345ABCDE12345ABCDE123456789',
    },
    customChains: [
      {
        network: 'shimmerevm-testnet',
        chainId: 1071,
        urls: {
          apiURL: 'https://explorer.evm.testnet.shimmer.network/api',
          browserURL: 'https://explorer.evm.testnet.shimmer.network/',
        },
      },
    ],
  }
  
  
};

export default config;
