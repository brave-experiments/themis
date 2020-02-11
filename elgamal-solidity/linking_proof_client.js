const Web3 = require('web3');
const solc = require('solc'); 
const fs = require('fs');

//const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://0.0.0.0:23000'), null, {}); // docker
//const web3 = new Web3(new Web3.providers.HttpProvider('http://3.135.198.73:22000'), null, {}); // side-chain
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545'), null, {}); // ganache

//const accountAddr = "0xed9d02e382b34818e88B88a309c7fe71E65f419d"; // docker
//const accountAddr = "0xde4737c66689177016f0c69c80a35cad710b6ca9"; // side-chain:
const accountAddr = "0x8aE43BAbEEe74757172772EBa754FD9E55513766"; // ganache

let deployedContractAddr;

// compile smart contract
const input = fs.readFileSync('./solidity/linking_proof.sol');
const output = solc.compile(input.toString(), 1);

 if (output.errors) {
   console.log("Error compiling solidity code")
   console.log(output.errors)
   process.exit();
 }

const bytecode = output.contracts[':Verifier'].bytecode;
const abi = JSON.parse(output.contracts[':Verifier'].interface);
const deploy_contract = new web3.eth.Contract(abi);
const params = {
  //data: bytecode,
  from: accountAddr,
  gasLimit: 500000
};


async function start() {
  await deploy_contract.deploy({data: "0x" + bytecode}).send(params, (err, res) => {
    if (err) {
      console.log("Error deploying contract: " + err);
       return;
    }
    console.log('Contract deployed. Address: ' + res);
  })
  .on('error', function(err){ console.log("Err: "+ err) })
  .on('transactionHash', function(tx){ 
    console.log("TxHash: "+ tx)
  })
  .on('receipt', function(receipt){
    console.log("receiptAddr: " + receipt.contractAddress);
  })
  .then(function(newContractInstance){
    console.log("newContractInstance " + newContractInstance.options.address)
    deployedContractAddr = newContractInstance.options.address;
});

  console.log("Done deploying contract")
  deploy_contract.options.address = deployedContractAddr;

  //await call_inner_product(deploy_contract, ciphertext_vector, scalar_vector);
}

start();

async function call_inner_product(contract, ciphertext_vector, scalar_vector) {
  let gas = 98265

  contract.methods.inner_product(ciphertext_vector, scalar_vector)
    .send({from: accountAddr, addr: deployedContractAddr })
    .then(receipt => {
      //console.log(">> Call Receipt received")
      //console.log(receipt)
  })
  .catch(err => {
    console.log("Some err was caught: "+err)
    process.exit(0)
  })
}

