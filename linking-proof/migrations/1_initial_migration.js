const Migrations = artifacts.require("Migrations");
const Verifier = artifacts.require("Verifier");
const Pairing = artifacts.require("Pairing");
const BN256G2 = artifacts.require("BN256G2");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Verifier);
  deployer.deploy(Pairing);
  deployer.deploy(BN256G2);
};
