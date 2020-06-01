const Themis2 = artifacts.require("ThemisPolicyContract2");
const Themis16 = artifacts.require("ThemisPolicyContract16");
const Themis128 = artifacts.require("ThemisPolicyContract128");

module.exports = function(deployer) {
  deployer.deploy(Themis2);
  deployer.deploy(Themis16);
  deployer.deploy(Themis128);
};
