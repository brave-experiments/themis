const Web3 = require("web3");
const Payment = require("../build/contracts/Payment.json")
const Escrow = require("../build/contracts/Escrow.json")

const BurnVerifier = require("../zether-contracts/BurnVerifier.json");
const CashToken = require("../zether-contracts/CashToken.json");
const ZetherVerifier = require("../zether-contracts/ZetherVerifier.json");
const ZSC = require("../zether-contracts/ZSC.json");

async function deploy(web3, from, gas, contractObj, args) {
    const abi = contractObj.abi;
    const bytecode = contractObj.bytecode;
    const contract = new web3.eth.Contract(abi);
    return new Promise((resolve, reject) => {
        contract.deploy({ data: bytecode, arguments: args})
            .send({from, gas})
            .on("error", (err) => {reject(err)})
            .on("receipt", (receipt) => {resolve(receipt)});
    });
};

async function deployContracts(web3) {
    // quorum-network node 1
    const n1addr = "0xed9d02e382b34818e88b88a309c7fe71e65f419d"
    const gas = 470000000;
    const policyArr = [1, 3, 4, 1, 3]; // TODO: encrypt
    let escrowAccountAddr;

    // Escrow contract
    try {
        const receiptEscrowContract = await deploy(web3, n1addr, gas, Escrow, [])
        console.log("\n EscrowContract Address: ", receiptEscrowContract.contractAddress)

        // updates escrowAccountAddr
        escrowAccountAddr = receiptEscrowContract.contractAddress;
    } catch(err) {
        console.log(err)
    }

    // Payment contract
    try {
        const args = [];
        args.push(policyArr);
        args.push(escrowAccountAddr);

        const receiptPaymentContract = await deploy(web3, n1addr, gas, Payment, args)
        console.log("\n PaymentContract Address: ", receiptPaymentContract.contractAddress)
    } catch(err) {
        console.log(err)
    }
}

const providerEndpoint = "http://localhost:22000" // quorum-network node 1
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:22000"))
web3.transactionConfirmationBlocks = 1;

deployContracts(web3)

module.exports = {
    deployContract: deploy,
};