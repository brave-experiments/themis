#![allow(dead_code)]

pub mod rpc;
mod utils;

use crate::rpc::SideChainService;

use web3::contract::Options;

use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::private::SecretKey;
use elgamal_bn::public::PublicKey;

use rand::thread_rng;

pub fn request_reward_computation(
    service: SideChainService<web3::transports::Http>,
    client_id: String,
    input: Vec<Ciphertext>,
    opts: Options,
) -> Result<String, ()> {
    let function_name = "calculate_aggregate".to_string();
    let encoded_input = crate::utils::encode_input_ciphertext(input);

    let result = service
        .call_function_remote(function_name, (encoded_input, client_id), opts)
        .unwrap();

    Ok(result.to_string())
}

pub fn generate_keys() -> (SecretKey, PublicKey) {
    let mut csprng = thread_rng();
    let sk = SecretKey::new(&mut csprng);
    let pk = PublicKey::from(&sk);
    (sk, pk)
}
