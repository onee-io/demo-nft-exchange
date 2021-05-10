const DemoNFT = artifacts.require("DemoNFT");

module.exports = function(deployer) {
  deployer.deploy(DemoNFT);
};

