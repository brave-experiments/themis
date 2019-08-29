const Web3 = require("web3");
const Verifer = require("../build/contracts/Escrow.json")

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
    let receiptVerifierContract;

    // Escrow contract
    try {
        const receipt = await deploy(web3, n1addr, gas, Verifer, [])
        console.log("\n VeriferContract Address: ", receipt.contractAddress)

        // updates receiptVerifierContract
        receiptVerifierContract = receipt.contractAddress;
    } catch(err) {
        console.log(err)
    }
}

const providerEndpoint = "http://localhost:23000" // quorum-network node 1
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:22000"))
web3.transactionConfirmationBlocks = 1;

deployContracts(web3)

module.exports = {
    deployContract: deploy,
};