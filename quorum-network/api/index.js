const Web3 = require('web3');

const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://0.0.0.0:23000'), null, {});
web3.eth.getProtocolVersion()
  .then(console.log)
  .catch(e => console.log(e));

