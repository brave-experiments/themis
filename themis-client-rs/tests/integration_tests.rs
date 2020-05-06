extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use elgamal_bn::ciphertext::Ciphertext;

use bn::{Group, G1};
use rand::thread_rng;

#[test]
fn test_request_reward_computation_and_fetch_storage() {
    let side_chain_addr = "http://127.0.0.1:9545".to_owned();
    let contract_addr = "c2fC3Ecfa5d00B34a6F35977884843B337870e2a".to_owned();

    let contract_abi_path = "../build/ThemisPolicyContract.abi".to_owned();

    let service = SideChainService::new(
        side_chain_addr.clone(),
        contract_addr.clone(),
        contract_abi_path,
    ).unwrap();

    let (sk, pk) = generate_keys();

    //let mut csprng = thread_rng();
    let interaction_vec = vec![pk.encrypt(&G1::one()), pk.encrypt(&G1::one())];

    let client_id = "client_id".to_owned();
    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("900000").unwrap());

    let tx_receipt =
        request_reward_computation(service.clone(), client_id.clone(), interaction_vec, opts);

    assert!(!tx_receipt.is_err());

    let result = fetch_aggregate_storage(service, client_id, Options::default());

    assert!(!result.is_err());
    let tuple = result.unwrap();

    let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];

    // TODO: refactor to utils
    let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk);
    assert!(!encrypted_encoded.is_err());

    let encrypted_encoded = encrypted_encoded.unwrap();

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);

    assert_eq!(decrypted_aggregate, G1::one() + G1::one() + G1::one(),);
}
