const Web3 = require('web3');
const solc = require('solc'); 
const fs = require('fs');

//const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://0.0.0.0:23000'), null, {}); // docker
//const web3 = new Web3(new Web3.providers.HttpProvider('http://3.135.198.73:22000'), null, {}); // side-chain
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545'), null, {}); // ganache

//const accountAddr = "0xed9d02e382b34818e88B88a309c7fe71E65f419d"; // docker
//const accountAddr = "0xde4737c66689177016f0c69c80a35cad710b6ca9"; // side-chain:
const accountAddr = "0xFd30711C93F5Eb26EEf85d87FdD75CeBa4b351c9"; // ganache

let deployedContractAddr;

// compile smart contract
const input = fs.readFileSync('./solidity/elgamal.sol');
const output = solc.compile(input.toString(), 1);

 if (output.errors) {
   console.log("Error compiling solidity code")
   console.log(output.errors)
   process.exit();
 }

const bytecode = output.contracts[':ElGamal'].bytecode;
const abi = JSON.parse(output.contracts[':ElGamal'].interface);
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

  deploy_contract.events.Aggregate((err, event) => {})
    .on('data', event => { console.log("Result: ("+ event.returnValues.aggr+")") })
    .on('error', (err) => { console.log(err) });

  let ciphertext_vector = [
    [ uint256('1368015179489954701390400359078579693043519447331113978918064868415326638035'), 
      uint256('9918110051302171585080402603319702774565515993150576347155970296011118125764')
    ],
    [ uint256('4503322228978077916651710446042370109107355802721800704639343137502100212473'), 
      uint256('6132642251294427119375180147349983541569387941788025780665104001559216576968')
    ],
    [ uint256('9836339169314901400584090930519505895878753154116006108033708428907043344230'), 
      uint256('2085718088180884207082818799076507077917184375787335400014805976331012093279')
    ],
    [ uint256('13093913218499068528079927169315581029488038715846819897949203493926040477433'), 
      uint256('18866812021242893984958271807367250411442129524282083647490667697096642392711')
    ]
  ];
  let scalar_vector = [1, 2, 1, 2];

  await call_inner_product(deploy_contract, ciphertext_vector, scalar_vector);
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

function uint256(i) {
  return web3.eth.abi.encodeParameter('uint256', i)
}
