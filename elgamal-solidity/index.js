var Web3 = require('web3')

const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545'), null, {}); // ganache


//Place your ABI here
var abi = require("./build/contracts/Verifier.json")

//Create instance of your contract -- 
//Second argument - contract address deployed on Ganache using Web3 provider 
var myContract = new web3.eth.Contract(abi, "0xF91d2CaE4A718F33183DD92c57a557185cA86352")

console.log(myContract.options)
console.log(myContract.methods)


// Call the function on smart contract
//A sample setProduct() takes one param 
//myContract.methods.setProduct("testproduct-created").call()