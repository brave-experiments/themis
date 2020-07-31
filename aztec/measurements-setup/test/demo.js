import utils from '@aztec/dev-utils';
const fs = require('fs').promises;

const aztec = require('aztec.js');
const dotenv = require('dotenv');
dotenv.config();
const secp256k1 = require('@aztec/secp256k1');

const ZkAssetMintable = artifacts.require('./ZkAssetMintable.sol');

const {
  proofs: {
    MINT_PROOF,
  },
} = utils;

const { JoinSplitProof, MintProof } = aztec;

contract('Private payment', accounts => {

  const bob = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_0);
  const sally = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a3 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a4 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a5 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a6 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a7 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a8 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a9 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a10 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a11 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a12 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a13 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a14 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a15 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);
  const a16 = secp256k1.accountFromPrivateKey(process.env.GANACHE_TESTING_ACCOUNT_1);

  let privatePaymentContract;

  beforeEach(async () => {
    privatePaymentContract = await ZkAssetMintable.deployed();
  });

  it('Bob should be able to deposit 100 and split it into multiple notes', async() => {
    const bobNote1 = await aztec.note.create(bob.publicKey, 50);

    const newMintCounterNote = await aztec.note.create(bob.publicKey, 50);
    const zeroMintCounterNote = await aztec.note.createZeroValueNote();
    const sender = privatePaymentContract.address;
    const mintedNotes = [bobNote1];

    const mintProof = new MintProof(
      zeroMintCounterNote,
      newMintCounterNote,
      mintedNotes,
      sender,
    );

    const mintData = mintProof.encodeABI();

    await privatePaymentContract.confidentialMint(MINT_PROOF, mintData, {from: accounts[0]});

    const t = new Date();
    // creates payment notes
    const sallyTaxiFee = await aztec.note.create(sally.publicKey, 10);
    const ac3 = await aztec.note.create(a3.publicKey, 10);    
    const ac4 = await aztec.note.create(a4.publicKey, 10);    
    const ac5 = await aztec.note.create(a5.publicKey, 10);    
    const ac6 = await aztec.note.create(a6.publicKey, 10);    
    const ac7 = await aztec.note.create(a7.publicKey, 10);    
    const ac8 = await aztec.note.create(a8.publicKey, 10);    
    const ac9 = await aztec.note.create(a9.publicKey, 10);    
    const ac10 = await aztec.note.create(a10.publicKey, 10);    
    const ac11 = await aztec.note.create(a11.publicKey, 10);    
    const ac12 = await aztec.note.create(a12.publicKey, 10);    
    const ac13 = await aztec.note.create(a13.publicKey, 10);    
    const ac14 = await aztec.note.create(a14.publicKey, 10);    
    const ac15 = await aztec.note.create(a15.publicKey, 10);    
    const ac16 = await aztec.note.create(a16.publicKey, 10);    

    const bobNote2 = await aztec.note.create(bob.publicKey, 130);

    const sendProofSender = accounts[0];
    const withdrawPublicValue = 0;
    const publicOwner = accounts[0];

    const sendProof = new JoinSplitProof(
        mintedNotes,
        [sallyTaxiFee, bobNote2, ac3, ac4, ac5, ac6, ac7, ac8, ac9, ac10, ac11, ac12, ac13, ac14, ac15, ac16],
        sendProofSender,
        withdrawPublicValue,
        publicOwner
    );
    const sendProofData = sendProof.encodeABI(privatePaymentContract.address);
    const sendProofSignatures = sendProof.constructSignatures(privatePaymentContract.address, [bob])
    await privatePaymentContract.confidentialTransfer(sendProofData, sendProofSignatures, {
      from: accounts[0],
    });

    const t2 = new Date();
    console.log(t2-t)
    await fs.appendFile('results.txt', t2-t+", ");
  })
});
