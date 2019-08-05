const Web3 = require('web3');

start();

function start() {
  const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://0.0.0.0:23000'), null, {});

  // subscriptions
  web3.eth.subscribe('pendingTransactions', (_, data) => {
    console.log("subscription.pendingTransactions::")
    console.log(data)
  })

  web3.eth.subscribe('syncing', (_, data) => {
    console.log("subscription.syncing::")
    console.log(data)
  })

  var logOpts = {
    address: [
      "0xed9d02e382b34818e88b88a309c7fe71e65f419d",
      "0xcA843569e3427144cEad5e4d5999a3D0cCF92B8e",
    ]
  }
  web3.eth.subscribe('logs', logOpts, (_, data) => {
    console.log("subscription.logs::")
    console.log(data)
  })

  web3.eth.subscribe('newBlockHeaders', (_, data) => {
    console.log(data.parentHash+"\n"+ data.hash+"\n")
  })


}
