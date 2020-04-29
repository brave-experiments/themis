extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use bn::{Fq, Fr, Group, G1};
use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::public::PublicKey;
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
        interaction_vec.clone(),
        opts,
    );

    assert!(!tx_receipt.is_err());

    let result = fetch_aggregate_storage(service, client_id, Options::default());

    assert!(!result.is_err());
    let tuple = result.unwrap();

    let encrypted_point: Point = [tuple.0, tuple.1, tuple.2, tuple.3];

    // TODO: refactor to utils
    let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk);
    assert!(!encrypted_encoded.is_err());

    let encrypted_encoded = encrypted_encoded.unwrap();

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
    let expected_aggregate = sk.decrypt(&aggregate);

    // let tx_proof_receipt = submit_proof_decryption(
    //     &service.clone(),
    //     &client_id.clone(),
    //     &interaction_vec,
    //     &opts
    // );

    assert_eq!(decrypted_aggregate, expected_aggregate,);
}
