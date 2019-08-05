const Web3 = require('web3');

start();

function start() {
  const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://0.0.0.0:23000'), null, {});

  var addr1 = "0xed9d02e382b34818e88B88a309c7fe71E65f419d"
  var addr2 = "0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e"

  web3.eth.getBalance(addr1)
    .then(console.log)
    .catch(console.log)
 
  web3.eth.getBalance(addr2)
    .then(console.log)
    .catch(console.log)
  
  // transaction
  var wei = 20000;
  let txHash = web3.eth.sendTransaction({from: addr1, to: addr2, value: wei})
    .then(data => data.transactionHash)
  
  // verifies that transaction is part of the blockchain
  txHash
    .then(web3.eth.getTransactionReceipt)
    .then(console.log)
  txHash
    .then(web3.eth.getTransaction)
    .then(console.log)
}

// 23000:
// default: 0xed9d02e382b34818e88B88a309c7fe71E65f419d
//new account: addr 0x87BE574C74A34Ba7b99c51aec6DD5f863EcFB7ec
//privkey 0xf98597a0e60cfc43b776e3001d2eee241503093ab58ebc8fd78350d70c47347d

// 23001:
// default: 0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e

// 23002:
// default: ca843569e3427144cead5e4d5999a3d0ccf92b8e
