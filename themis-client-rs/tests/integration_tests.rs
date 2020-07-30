extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use elgamal_bn::ciphertext::Ciphertext;

use bn::{Fr, Group, G1};
use rand::thread_rng;
use rand::Rng;
use std::env;

#[test]
fn test_request_reward_computation_and_fetch_storage() {
    let side_chain_addr = match env::var("SIDECHAIN_ADDR") {
        Ok(addr) => addr.to_owned(),
        Err(_) => {
            println!("Using local sidechain addr.");
            "http://127.0.0.1:9545".to_owned()
        }
    };
    let contract_addr = match env::var("CONTRACT_ADDR") {
        Ok(addr) => addr.to_owned(),
        Err(_) => panic!("No contract address set (define CONTRACT_ADDR env var)"),
    };

    let contract_abi = include_bytes!["./ThemisPolicyContract_Test.abi"];

    let service =
        SideChainService::new(side_chain_addr.clone(), contract_addr.clone(), contract_abi)
            .unwrap();

    let (sk, pk) = generate_keys();

    let interaction_vec = vec![pk.encrypt(&G1::one()), pk.encrypt(&G1::one())];

    let mut csprng = thread_rng();
    let nonce = csprng.gen_range(0, 100000);
    let nonce: String = nonce.to_string();
    let client_id = "client_id".to_owned() + &nonce;

    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("900000").unwrap());
    //opts.gas = Some(web3::types::U256::from_dec_str("1600000").unwrap());

    let tx_receipt = request_reward_computation(
        service.clone(),
        client_id.clone(),
        pk,
        interaction_vec,
        opts,
    );

    assert!(!tx_receipt.is_err());

    // Waits for storage update
    use std::{thread, time};
    thread::sleep(time::Duration::from_secs(3));

    println!("{:?}", client_id);

    let result = fetch_aggregate_storage(service, client_id, Options::default());

    assert!(!result.is_err());
    let tuple = result.unwrap();

    println!("{:?}", tuple);

    let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];

    let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk);
    assert!(!encrypted_encoded.is_err());

    let encrypted_encoded = encrypted_encoded.unwrap();

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);

    let scalar_aggregate = utils::recover_scalar(decrypted_aggregate, 16);
    assert!(!scalar_aggregate.is_err());

    assert_eq!(decrypted_aggregate, G1::one() + G1::one() + G1::one(),);

    let scalar_aggregate = scalar_aggregate.unwrap();
    assert_eq!(scalar_aggregate, Fr::from_str("3").unwrap());
}
