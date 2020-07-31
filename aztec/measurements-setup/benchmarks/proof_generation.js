import utils from "@aztec/dev-utils";

const aztec = require("aztec.js");
const dotenv = require("dotenv");
dotenv.config();
const secp256k1 = require("@aztec/secp256k1");

const ZkAssetMintable = artifacts.require("./ZkAssetMintable.sol");

const {
  proofs: { MINT_PROOF }
} = utils;

const { JoinSplitProof, MintProof } = aztec;

contract("Benchmark multiple AZTEC notes creation", accounts => {
  const payer = secp256k1.accountFromPrivateKey(
    process.env.GANACHE_TESTING_ACCOUNT_0
  );
  const receiver1 = secp256k1.accountFromPrivateKey(
    process.env.GANACHE_TESTING_ACCOUNT_1
  );
  let privatePaymentContract;

  beforeEach(async () => {
    privatePaymentContract = await ZkAssetMintable.deployed();
  });

  //console.log(process.env);

  it("Payer builds split notes and performs payments", async () => {

    // 1. Payer mints 1000 AZTEC tokens to use for payments
    const initialPayerBalance = 1000;
    const note1 = await aztec.note.create(payer.publicKey, initialPayerBalance);

    const newMintCounterNote = await aztec.note.create(payer.publicKey, initialPayerBalance);
    const zeroMintCounterNote = await aztec.note.createZeroValueNote();
    const sender = accounts[0];
    const mintedNotes = [note1];

    const mintProof = new MintProof(
      zeroMintCounterNote,
      newMintCounterNote,
      mintedNotes,
      sender
    );

    // 2. Payer mints ETH into AZTEC tokens to be paid through AZTEC protocol
    const mintData = mintProof.encodeABI();
    await privatePaymentContract.confidentialMint(MINT_PROOF, mintData, {
      from: accounts[0]
    });

    console.log("1. Payer minted AZTEC (remote call)");

    // prepares notes for receivers
    let notes = [];

    let timer_startGenerateNotes = new Date();

    const nrPayments = 100;
    const amount = 10;
    for (let i = 0; i < nrPayments; i++) {
      const receiverNote = await aztec.note.create(receiver1.publicKey, amount);
      notes.push(receiverNote);
    }
    const remaining_note = await aztec.note.create(payer.publicKey,
      initialPayerBalance - (nrPayments * amount)); // note with remainer of minter
  
    let timeGenerateNotes = new Date() - timer_startGenerateNotes;

    notes.push(remaining_note);
    console.log("2. Payer generated all notes");

    const sendProofSender = accounts[0];
    const withdrawPublicValue = 0;
    const publicOwner = accounts[0];
    
    let timer_startBuildJoinSplitProof = new Date();

    // builds up join split proof
    const sendProof = new JoinSplitProof(
      mintedNotes,
      notes,
      sendProofSender,
      withdrawPublicValue,
      publicOwner
    );

    let timeBuildJoinSplitProof = new Date() - timer_startBuildJoinSplitProof;

    console.log("3. Payer built join split proof with all notes");

    const sendProofData = sendProof.encodeABI(privatePaymentContract.address);
    const sendProofSignatures = sendProof.constructSignatures(
      privatePaymentContract.address,
      [payer]

    );

    // sends proofs for sidechain to verify
    //await privatePaymentContract.methods["confidentialTransfer(bytes,bytes)"](
    //  sendProofData,
    //  sendProofSignatures,
    //  { from: accounts[0] },
    //);
    // console.log("4. Payer sent join split proof to sidechain (remote call)");

    // Benchmark report
    console.log("Time generating "+ nrPayments+" notes: " + timeGenerateNotes + " ms")
    console.log("Time building Join Split proof of "+ nrPayments+" notes: " + timeBuildJoinSplitProof + " ms")

  });
});
