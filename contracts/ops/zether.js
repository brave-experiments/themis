const Web3 = require("web3");
const deployContract = require('deploy').deployContract;

const BurnVerifier = require("../zether-contracts/BurnVerifier.json");
const CashToken = require("../zether-contracts/CashToken.json");
const ZetherVerifier = require("../zether-contracts/ZetherVerifier.json");
const ZSC = require("../zether-contracts/ZSC.json");


const providerEndpoint = "http://localhost:22000" // quorum-network node 1
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:22000"))
web3.transactionConfirmationBlocks = 1;