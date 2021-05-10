const DemoNFT = artifacts.require("DemoNFT");
const Exchange = artifacts.require("Exchange");

module.exports = function(deployer) {
  deployer.deploy(DemoNFT);
  deployer.deploy(Exchange);
};

