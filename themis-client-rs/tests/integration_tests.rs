extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use bn::{Group, G1};
use rand::thread_rng;

#[test]
fn test_request_reward_computation_and_fetch_storage() {
    //let side_chain_addr = "http://127.0.0.1:9545".to_owned();
    //let contract_addr = "c2fC3Ecfa5d00B34a6F35977884843B337870e2a".to_owned();
    let side_chain_addr = "http://18.222.161.183:22000".to_owned();
    let contract_addr = "e64B1F131301662B7d27444c2EffA22815Ef1558".to_owned();

    let contract_abi_path = "../build/ThemisPolicyContract.abi".to_owned();

    let service = SideChainService::new(
        side_chain_addr.clone(),
        contract_addr.clone(),
        contract_abi_path,
    );

    let (_sk, pk) = generate_keys();

    let mut csprng = thread_rng();
    let interaction_vec = vec![
        pk.encrypt(&G1::random(&mut csprng)),
        pk.encrypt(&G1::random(&mut csprng)),
    ];

    let client_id = "client_id".to_owned();
    let tx_receipt = request_reward_computation(
        service.clone(),
        client_id.clone(),
        interaction_vec,
        Options::default(),
    );

    assert!(!tx_receipt.is_err());

    let result = fetch_aggregate_storage(service, client_id, Options::default());

    assert!(!result.is_err());
    let tuple = result.unwrap();

    // TODO: remove zero() and fix points when we have things work e2e
    let encrypted_point: Point = [tuple.0, tuple.1, tuple.2, tuple.3];
    assert_eq!(encrypted_point[0], web3::types::U256::zero());
}
