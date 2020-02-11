const Web3 = require('web3');
const bn128 = require('@aztec/bn128');
const assert = require('assert');
const BN = require('bn.js');
const elliptic = require('elliptic.js');

//const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://0.0.0.0:23000'), null, {}); // docker
//const web3 = new Web3(new Web3.providers.HttpProvider('http://3.135.198.73:22000'), null, {}); // side-chain
const web3 = new Web3(new Web3.providers.WebsocketProvider('ws://127.0.0.1:8545'), null, {}); // ganache

//const accountAddr = "0xed9d02e382b34818e88B88a309c7fe71E65f419d"; // docker
//const accountAddr = "0xde4737c66689177016f0c69c80a35cad710b6ca9"; // side-chain:
const accountAddr = "0xFd30711C93F5Eb26EEf85d87FdD75CeBa4b351c9"; // ganache

let keypair = getKeyPair();

let plaintext = [
  new BN("4503322228978077916651710446042370109107355802721800704639343137502100212473", 10),
  new BN("6132642251294427119375180147349983541569387941788025780665104001559216576968", 10)
];

let ciphertext = encrypt(plaintext, keypair.pubKey);
let decrypted_plaintext = decrypt(ciphertext, keypair.privKey);

console.log("\nPlaintext: " + plaintext)
console.log("\nCiphertext: " + ciphertext)
console.log("\nDecrytped Plaintext: " + decrypted_plaintext)

assert.equal(plaintext, decrypted_plaintext);


function encrypt(plaintext, pubkey) {
  let rndScalar = bn128.randomGroupScalar();
  let x = rndScalar // TODO: change for (rndScalar * G)

  let y_tmp = pubkey[0].mul(rndScalar);
  let y = plaintext.add(y_tmp);

  return [x, y];
}

function decrypt(ciphertext, privkey) {
  let pt_tmp = ciphertext[0].mul(privkey);
  return ciphertext[1].sub(pt_tmp);
}

function getKeyPair() {
  let privKey = new BN('2', 10);
  let pubKey = [
    new BN('1368015179489954701390400359078579693043519447331113978918064868415326638035', 10), 
    new BN('9918110051302171585080402603319702774565515993150576347155970296011118125764', 10)
   ];
  return { privKey, pubKey }
}

function uint256(i) {
  return web3.eth.abi.encodeParameter('uint256', i)
}

// TODO: finish
function generateKeyPair() {
  let point = bn128.randomPoint();
  //console.log(point.x.toString())
  //console.log(uint256(point.x.toString()))
  //console.log(point.y.toString())
  //console.log(uint256(point.y.toString()))
}