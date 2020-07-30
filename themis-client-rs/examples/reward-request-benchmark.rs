extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use bn::{Fr, Group, G1};
use rand::thread_rng;
use rand::Rng;
use std::time::SystemTime;
use std::{env, process};

pub const POLICY_SIZE: usize = 64;

fn main() {
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

    //let contract_abi = include_bytes!["../build/ThemisPolicyContract.abi"]; // 2 ads
    //let contract_abi = include_bytes!["../build/ThemisPolicyContract_16ads.abi"];
    let contract_abi = include_bytes!["../build/ThemisPolicyContract_64ads.abi"];
    //let contract_abi = include_bytes!["../build/ThemisPolicyContract_128ads.abi"];
    //let contract_abi = include_bytes!["../build/ThemisPolicyContract_256ads.abi"];
    let service =
        SideChainService::new(side_chain_addr.clone(), contract_addr.clone(), contract_abi)
            .unwrap();

    // start counting time
    let start_ts = SystemTime::now();

    let (sk, pk) = generate_keys();

    // generate interaction vector with `policy_vector_size` entries
    //let policy_vector_size = 2;
    //let policy_vector_size = 16;
    let policy_vector_size = POLICY_SIZE;
    let mut interaction_vec = vec![];
    for _i in 0..policy_vector_size {
        interaction_vec.push(pk.encrypt(&G1::one()));
    }

    let mut csprng = thread_rng();
    let rnd = csprng.gen_range(0, 100000);
    let rnd: String = rnd.to_string();
    let client_id = "client_id".to_string() + &rnd;

    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("30000000").unwrap());

    let tx_receipt = request_reward_computation(
        service.clone(),
        client_id.clone(),
        pk,
        interaction_vec.clone(),
        opts,
    );

    // fail if error
    tx_receipt.unwrap();

    use std::{thread, time};
    let delay = 10;
    thread::sleep(time::Duration::from_secs(delay));

    let result = fetch_aggregate_storage(service, client_id.clone(), Options::default());

    let tuple = match result {
        Ok(r) => r,
        Err(_e) => {
            //println!("Error fetching aggregate storage: {:?}", e);
            println!(" # ");
            process::exit(0x1000);
        }
    };

    let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];
    let encrypted_encoded = match utils::decode_ciphertext(encrypted_point, pk) {
        Ok(r) => r,
        Err(_e) => {
            //println!("Error decoding ciphertext: {:?}", e);
            println!(" # ");
            process::exit(0x1000);
        }
    };

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
    let scalar_aggregate = match utils::recover_scalar(decrypted_aggregate, 16) {
        Ok(r) => r,
        Err(_e) => {
            //println!("Error decrypting aggregate: {:?}", e);
            println!(" # ");
            process::exit(0x1000);
        }
    };

    //assert_eq!(scalar_aggregate, Fr::from_str("3").unwrap()); // 2ads
    //assert_eq!(scalar_aggregate, Fr::from_str("17").unwrap()); // 16 ads
    assert_eq!(scalar_aggregate, Fr::from_str("40").unwrap()); // 64 ads
                                                               //assert_eq!(scalar_aggregate, Fr::from_str("60").unwrap()); // 128 ads
                                                               //assert_eq!(scalar_aggregate, Fr::from_str("120").unwrap()); // 256 ads

    //println!("Time elapsed: {:?} ({:?})", start_ts.elapsed(), client_id);
    print!(
        "{:?}, ",
        start_ts.elapsed().unwrap().as_secs_f64() - delay as f64
    );
}
