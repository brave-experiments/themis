extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use bn::{Fq, Fr, Group, G1};
use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::public::{PublicKey, get_point_as_hex_str, get_scalar_as_hex_str};
use rand::thread_rng;

fn main() {
    let side_chain_addr = "http://127.0.0.1:9545".to_owned();
    let contract_addr = "44D46221f1ca0bBEDBd5aD2b1e660794b9767afd".to_owned();
    let contract_abi_path = "../build/ThemisPolicyContract.abi".to_owned();

    let service = SideChainService::new(
        side_chain_addr.clone(),
        contract_addr.clone(),
        contract_abi_path,
    ).unwrap();

    let (sk, pk) = generate_keys();
    let ctxt_one = pk.encrypt(&G1::one());

    // Now we encode the policy vector. This MUST be the same as in the smart contract
    let one = Fr::one();
    let policy_vector = [one, one + one];

    //let mut csprng = thread_rng();
    let interaction_vec = vec![ctxt_one.clone(), ctxt_one.clone()];

    let multiplied_interactions: Vec<Ciphertext> = interaction_vec
        .clone()
        .into_iter()
        .zip(policy_vector.into_iter())
        .map(|(x, &y)| x * y)
        .collect();

    let aggregate: Ciphertext = multiplied_interactions[0] + multiplied_interactions[1];

    let client_id = "client_id".to_owned();
    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("900000").unwrap());

    let tx_receipt = request_reward_computation(
        service.clone(),
        client_id.clone(),
        pk,
        interaction_vec.clone(),
        opts.clone(),
    );

    assert!(!tx_receipt.is_err());

    let result = fetch_aggregate_storage(service.clone(), client_id.clone(), Options::default());

    assert!(!result.is_err());
    let tuple = result.unwrap();

    let encrypted_point: Ctxt = [tuple.0, tuple.1, tuple.2, tuple.3];

    // TODO: refactor to utils
    let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk);
    assert!(!encrypted_encoded.is_err());

    let encrypted_encoded = encrypted_encoded.unwrap();

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
    let expected_aggregate = sk.decrypt(&aggregate);

    assert_eq!(decrypted_aggregate, expected_aggregate,);

    let proof_dec = sk.proof_decryption_as_string(&encrypted_encoded,&decrypted_aggregate).unwrap();

    println!("Public Key hexadecimal: {:?}", pk.get_point_hex_string().unwrap());

    println!("Plaintext hexadecimal: {:?}, {:?}", proof_dec[0], proof_dec[1]);

    println!("Ciphertext hexadecimal: {:?}", encrypted_encoded.get_points_hex_string());

    println!("Announcement G: {:?}, {:?}", proof_dec[2], proof_dec[3]);
    println!("Announcement Ctxt: {:?}, {:?}", proof_dec[4], proof_dec[5]);
    println!("Response: {:?}", proof_dec[6]);

    let tx_receipt_proof = submit_proof_decryption(
        &service,
        &client_id,
        &proof_dec,
        &opts,
    );

    assert!(!tx_receipt_proof.is_err());

    let proof_result = fetch_proof_verification(&service, &client_id, &Options::default());

    assert!(!proof_result.is_err());
    let success = proof_result.unwrap();

    println!("Proof verified correctly: {:?}", success);
}
