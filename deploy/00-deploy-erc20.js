const { getNamedAccounts, deployments, network } = require("hardhat");
const { developmentChains } = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  console.log(deployer);
  const devUSDC = await deploy("devUSDC", {
    from: deployer,
    args: [],
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`ourToken deployed at ${devUSDC.address}`);
  console.log(
    !developmentChains.includes(network.name) , process.env.ETHERSCAN_API
  );
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API
  ) {

    // await verify(devUSDC.address, []);
  }
};

module.exports.tags = ["all", "token"];
