require("@nomicfoundation/hardhat-toolbox");
//require("dotenv").config()
require("@chainlink/env-enc").config()
require("./tasks/deploy-fundme").config()

const SEPOLIA_URL = process.env.SEPOLIA_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const ETHERSCANAPI = process.env.ETHERSCAN_API_KRY

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  //指定部署的网络
  // networks: {
  //   sepolia: {
  //     url: SEPOLIA_URL,
  //     accounts: [PRIVATE_KEY, ...]
  //     chainid: 11155111 //sepolia的chainid
  //   }
  // }
  //只使用这样配置的问题：上传项目之后，别人会在这里看到我们的敏感信息，因此可以使用.env来配置，使用上面的process.env命令获得url和account并保存为常量，然后在这里使用，然后使用env-enc加密env文件信息，然后删除.env文件

  //hardhat verify
  etherscan: {
    apiKey: ETHERSCANAPI
  }
};
