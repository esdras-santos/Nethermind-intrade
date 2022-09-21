import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@shardlabs/starknet-hardhat-plugin";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
};

export default config;
