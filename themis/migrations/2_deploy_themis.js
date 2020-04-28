const Themis = artifacts.require("ThemisPolicyContract");

module.exports = function(deployer) {
  deployer.deploy(Themis);
};
