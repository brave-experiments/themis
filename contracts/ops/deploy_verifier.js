const Web3 = require("web3");
const Verifer = require("../build/contracts/Verifier.json")

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

//deployContracts(web3)

// quorum-network node 
const nodeaddr = "0xed9d02e382b34818e88b88a309c7fe71e65f419d"

const params = {
        "proof": {
            "a": ["0x179ed488c21b5ef3bb9d07bd367b7a04014eb7b66ce13132b6a44eac31966098", "0x0ed910b8eb90375d6003bc3e36495d334f9845cbdb3bae8110b7b0c9015305c9"],
            "b": [["0x1bc828c8c99a9d6ac5a66ca917e2e31a035ef5c716194a2e9027878d2af16a30", "0x23cea765e24b55b9612f58dfe8d02781dc1a10cdbb2d0e85ac6ddb9f39c32be0"], ["0x2468da4c415e80fe26721e17ca18dee0999bd65891df5984611587108a202901", "0x141bb5fa110a9dca54d289a91cf03a877381ce2b8b400ecdfef6a10c4edb0f4b"]],
            "c": ["0x1c814e3429ad48ac323d71940227d2dd6ab5ceb24db113aa9ce79f983c6dc213", "0x0946f02a89ddfe05c16475b78f08f635da2f60c6881394f82b7c257d2fe76070"]
        },
        "inputs": ["0x000000000000000000000000000000000000000000000000000000000000001d", "0x0000000000000000000000000000000000000000000000000000000000000001"]
    }

async function transaction(web3, contractAddr) {
    const abi = Verifer.abi;
    const contract = web3.eth.Contract(abi, contractAddr);

    let init = new Date();

    // call verifier 


    //Verifier.at(contractAddr).verifyTx(A, A_p, B, B_p, C, C_p, H, K, [...publicInputs, ...outputs])
    const args = [
    ]

    contract.methods.at(contractAddr).call({
        from: nodeaddr,
        arguments: args
    }, function(error, result){
        if (error) {}
        else {

            
        let after = new Date();
        let time_spent = after - init;
        console.log(time_spent)
        }

    });


}






module.exports = {
    deployContract: deploy,
};