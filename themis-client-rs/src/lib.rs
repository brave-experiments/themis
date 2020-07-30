#![allow(dead_code)]
pub mod errors;
pub mod rpc;
pub mod utils;

extern crate hex;
extern crate sha2;

use crate::errors::Error;
use crate::rpc::SideChainService;

use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::private::SecretKey;
use elgamal_bn::public::PublicKey;

use rand::thread_rng;
use web3::contract::Options;
use web3::types::U256;

//pub const POLICY_SIZE: usize = 64;
pub const POLICY_SIZE: usize = 128;
//pub const POLICY_SIZE: usize = 256;

pub type CiphertextSolidity = [U256; 4];
pub type Point = [U256; 2];
// two points and one scalar
pub type Proof = [U256; 7];

pub fn submit_proof_decryption(
    service: &SideChainService,
    client_id: &String,
    input: &[String; 7],
    opts: &Options,
) -> Result<String, ()> {
    let function_name = "submit_proof_decryption".to_owned();

    let encoded_input = crate::utils::encode_proof_decryption(&input).unwrap();

    let client_id = utils::encode_client_id(client_id.clone());

    let result = service
        .call_function_remote(function_name, (encoded_input, client_id), opts.clone())
        .unwrap();

    Ok(result.to_string())
}

pub fn fetch_proof_verification(
    service: &SideChainService,
    client_id: &String,
    opts: &Options,
) -> Result<bool, Error> {
    let function_name = "fetch_proof_verification".to_string();

    let client_id = utils::encode_client_id(client_id.clone());

    let result = service.query_bool_function_remote(&function_name, client_id, &opts)?;
    Ok(result)
}

pub fn request_reward_computation(
    service: SideChainService,
    client_id: String,
    public_key: PublicKey,
    input: Vec<Ciphertext>,
    opts: Options,
) -> Result<String, Error> {
    let function_name = "calculate_aggregate".to_string();
    let encoded_input_raw = crate::utils::encode_input_ciphertext(input)?;

    let mut encoded_input: [CiphertextSolidity; POLICY_SIZE] =
        [CiphertextSolidity::default(); POLICY_SIZE];
    for i in 0..encoded_input_raw.len() {
        encoded_input[i] = encoded_input_raw[i];
    }
    let encoded_pk = utils::encode_public_key(public_key)?;
    let client_id = utils::encode_client_id(client_id);

    //println!("{:?}", client_id);

    let result = service.call_function_remote(
        function_name,
        (encoded_input, encoded_pk, client_id),
        opts,
    )?;

    Ok(result.to_string())
}

pub fn fetch_aggregate_storage(
    service: SideChainService,
    client_id: String,
    opts: Options,
) -> Result<(U256, U256, U256, U256), Error> {
    let function_name = "fetch_encrypted_aggregate".to_string();

    let client_id = utils::encode_client_id(client_id);

    let result = service.query_function_remote(function_name, client_id, opts)?;
    Ok(result)
}

pub fn generate_keys() -> (SecretKey, PublicKey) {
    let mut csprng = thread_rng();
    let sk = SecretKey::new(&mut csprng);
    let pk = PublicKey::from(&sk);
    (sk, pk)
}
