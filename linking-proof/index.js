var Web3 = require('web3')

const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545'), null, {}); // ganache

const accountAddr = "0x390d8f0E85bdF7117c149B33b4e056969883f9BE";
const contractAddr = "0xF91d2CaE4A718F33183DD92c57a557185cA86352";

var abi = require("./build/contracts/Verifier.json").abi;
var contract = new web3.eth.Contract(abi, contractAddr)

const input = require("./input1")
//const input = require("./input32")


const start = new Date();

contract.methods.verifyTx(input.proof.a, input.proof.b, input.proof.c, input.inputs)
  .call({ from: accountAddr, addr: contractAddr })
  .then(result => {
    console.log(result)

    const secs = (new Date() - start) / 1000;
    console.log(secs + "s");
  })
  .catch(console.error)
