#![allow(dead_code)]
pub mod rpc;
pub mod utils;

extern crate hex;
extern crate sha2;

use crate::rpc::SideChainService;

use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::private::SecretKey;
use elgamal_bn::public::PublicKey;

use rand::thread_rng;
use web3::contract::Options;
use web3::types::U256;

pub const MAX_PARALLEL_REQUESTS: usize = 64;
pub const POLICY_SIZE: usize = 2;

pub type Point = [U256; 4];

pub fn request_reward_computation(
    service: SideChainService,
    client_id: String,
    input: Vec<Ciphertext>,
    opts: Options,
) -> Result<String, ()> {
    let function_name = "calculate_aggregate".to_string();

    let encoded_input_raw = crate::utils::encode_input_ciphertext(input).unwrap();
    //let encoded_input_raw = crate::utils::encode_input_ciphertext_ok(input).unwrap();

    let mut encoded_input: [Point; POLICY_SIZE] = [Point::default(); POLICY_SIZE];
    for i in 0..encoded_input_raw.len() {
        encoded_input[i] = encoded_input_raw[i];
    }
    let client_id = utils::encode_client_id(client_id);

    let result = service
        .call_function_remote(function_name, (encoded_input, client_id), opts)
        .unwrap();

    Ok(result.to_string())
}

pub fn fetch_aggregate_storage(
    service: SideChainService,
    client_id: String,
    opts: Options,
) -> Result<(U256, U256, U256, U256), web3::contract::Error> {
    let function_name = "fetch_encrypted_aggregate".to_string();

    let client_id = utils::encode_client_id(client_id);

    let result = service.query_function_remote(function_name, client_id, opts);
    Ok(result.unwrap())
}

pub fn generate_keys() -> (SecretKey, PublicKey) {
    let mut csprng = thread_rng();
    let sk = SecretKey::new(&mut csprng);
    let pk = PublicKey::from(&sk);
    (sk, pk)
}
