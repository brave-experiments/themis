#[cxx::bridge(namespace = brave::themis_client)]

mod ffi {
    struct ResultReward {
        pub aggregate: u32,
        pub error: bool,
    }

    extern "C" {
        include!("cpp/header.h");
        fn run_example();
    }

    extern "Rust" {
        fn request_reward(
            client_id: String,
            iteration_array: Vec<u8>,
        ) -> ResultReward;
    }
}

use themis_client::rpc;
use themis_client::utils;

fn request_reward(
    client_id: String,
    user_interactions: Vec<u8>,
) -> ffi::ResultReward {

    // refactor as input
    let side_chain_addr = "http://127.0.0.1:9545".to_owned();
    let contract_addr = "c2fC3Ecfa5d00B34a6F35977884843B337870e2a".to_owned();
    let contract_abi_path = "../build/ThemisPolicyContract.abi".to_owned();

    let service = match rpc::SideChainService::new(
         side_chain_addr.clone(),
         contract_addr.clone(),
         contract_abi_path,
    ) {
        Ok(srv) => srv,
        Err(_) => return ffi::ResultReward::default(),
    };

    let (sk, pk) = themis_client::generate_keys();

    let encrypted_interactions = match utils::encrypt_input(user_interactions, pk) {
        Ok(vec) => vec,
        Err(_) => return ffi::ResultReward::default(),
    };

    let result = themis_client::request_reward_computation(
        service.clone(), 
        client_id.clone(), 
        encrypted_interactions, 
        utils::default_options(),
    );

    if result.is_err() {
        return ffi::ResultReward::default();
    }

    let encoded_aggr = match themis_client::fetch_aggregate_storage(
        service,
        client_id,
        utils::default_options(),
    ) {
        Ok(enc_point) => enc_point,
        Err(_) => return ffi::ResultReward::default(),
    };

    let encrypted_point = [ encoded_aggr.0, encoded_aggr.1, encoded_aggr.2, encoded_aggr.3 ];

    let encrypted_aggr = match utils::decode_ciphertext(encrypted_point, pk) {
        Ok(aggr) => aggr, 
        Err(_) => return ffi::ResultReward::default(),
    };

    let _decrypted_aggregate = sk.decrypt(&encrypted_aggr); 
    
    // #TODO: send decrypted aggregate and proof of correct decryption...
    // #TODO: bruteforce bn::G1 to get back the aggregate result
    
    ffi::ResultReward{
        error: false,
        aggregate: 0, //TODO: replace with brute forced bn::G1
    }
}

trait Error {
    fn default() -> Self;
}

impl Error for ffi::ResultReward {
    fn default() -> ffi::ResultReward {
        ffi::ResultReward {
            error: true,
            aggregate: 0,
        }
    }
}

fn main() {
    ffi::run_example();
}
