const { network } = require("hardhat");
const { verify } = require("../utils/verify");
const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");
module.exports = async (hre) => {
  const { getNamedAccounts, deployments } = hre;
  let { deploy, log } = deployments;
  let { deployer } = await getNamedAccounts();
  let chainId = network.config.chainId;
  let ethUsdPriceFeedAddress;
  // networkConfig[chainId]['ethUsdPriceFeed']
  if (developmentChains.includes(network.name)) {
    let ethUsdAggregator = await deployments.get("MockV3Aggregator");
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }
  let args = [ethUsdPriceFeedAddress,"0x79DA5f274348fbCE51df6e9c9776C1D6F908d69E"];
  const stake = await deploy("Stake", {
    from: deployer,
    args: args,
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  console.log(stake)
  if (
    !developmentChains.includes(network.name) &&
    process.env.ETHERSCAN_API
  ) {
    await verify(stake.address, args);
  }
};
module.exports.tags = ["all", "stake"];
