const Web3 = require('web3');
const fs = require('fs');
const solc = require('solc'); 

//const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://0.0.0.0:23000'), null, {});
const web3 = new Web3(new Web3.providers.HttpProvider('http://3.135.198.73:22000'), null, {});

const accountAddr = "0xde4737c66689177016f0c69c80a35cad710b6ca9";
const contractAddr = "0x5e1FCaDCC9917F3e078c6906cBD0dD200b25C0Eb";

const input = fs.readFileSync('./solidity/elgamal.sol');
const output = solc.compile(input.toString(), 1);
const bytecode = output.contracts[':ElGamal'].bytecode;
const abi = JSON.parse(output.contracts[':ElGamal'].interface);

const contract = new web3.eth.Contract(abi);
contract.options.address = contractAddr;

let ciphertext_vector = [[1, 1], [1, 1]];
let scalar_vector = [1, 1];
call_inner_product(contract, ciphertext_vector, scalar_vector);

//call_hello(contract);


// contract.methods.inner_product(ciphertext_vector, scalar_vector).estimateGas({gas: 8000}, function(error, gasAmount){
//     if(gasAmount == 8000) console.log('Method ran out of gas');
//     console.log("8000 OK")
//     console.log(gasAmount)
//     console.log(error)
// });

async function call_inner_product(contract, ciphertext_vector, scalar_vector) {

  contract.methods.inner_product(ciphertext_vector, scalar_vector)
    .send({from: accountAddr, addr: contractAddr})
    .then(receipt => {
      console.log("Call receipt")
      console.log(receipt)
  })
  .catch(err => {
    console.log("Some err was caught: "+err)
    process.exit(0)
  })
}

async function call_hello(contract) { 
 let vec = [[1, 0]];
 const receipt = await contract.methods.hello(vec)
   .send({from: accountAddr, addr: contractAddr})
   .then(receipt => {
     console.log(receipt)
 })
  .catch(err => {
    console.log("Some err was caught: "+err)
    process.exit(0)
  })
}