var Web3 = require('web3')

const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545'), null, {}); // ganache

const accountAddr = "0x7226FD7d2B7245eDEc1F5AAe6B51095A5Fb9e89d";
const contractAddr = "0x979aA9c0072E0A4DB157Df4956cFce35dDF68B8D";

var abi = require("./build/contracts/Verifier.json").abi;
var contract = new web3.eth.Contract(abi, contractAddr)

//const input = require("./input1")
const input = require("./input32")


const start = new Date();

contract.methods.verifyTx(input.proof.a, input.proof.b, input.proof.c, input.inputs)
  .call({ from: accountAddr, addr: contractAddr })
  .then(result => {
    console.log(result)

    const secs = (new Date() - start) / 1000;
    console.log(secs + "s");
  })
  .catch(console.error)
