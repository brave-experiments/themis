extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use std::time::SystemTime;
use rand::thread_rng;
use bn::{Group, G1, Fr};
use rand::Rng; 
use std::{env, process};

fn main() {
    let side_chain_addr = "http://127.0.0.1:9545/".to_owned();
    // let side_chain_addr = match env::var("SIDECHAIN_ADDR") {
    //     Ok(addr) => addr.to_owned(),
    //     Err(_) => {
    //         println!("Using local sidechain addr.");
    //         "http://127.0.0.1:9545".to_owned()
    //     }
    // };

    let contract_addr = "44D46221f1ca0bBEDBd5aD2b1e660794b9767afd".to_owned();
    // let contract_addr = match env::var("CONTRACT_ADDR") {
    //     Ok(addr) => addr.to_owned(),
    //     Err(_) => panic!("No contract address set (define CONTRACT_ADDR env var)"),
    // };


    let contract_abi = include_bytes!["../build/ThemisPolicyContract.abi"]; // generic
    // let contract_abi = include_bytes!["../build/ThemisPolicyContract_2ads.abi"]; // 2 ads
    //let contract_abi = include_bytes!["../build/ThemisPolicyContract_16ads.abi"];
    // let contract_abi = include_bytes!["../build/ThemisPolicyContract_16ads.abi"];
    let service = SideChainService::new(
        side_chain_addr.clone(), contract_addr.clone(), contract_abi).unwrap();

    // start counting time
    let start_ts = SystemTime::now();

    let (sk, pk) = generate_keys();

    // generate interaction vector with `policy_vector_size` entries
    let policy_vector_size = 2;
    // let policy_vector_size = 16;
    //let policy_vector_size = 128;
    let mut interaction_vec = vec![];
    for _i in 0..policy_vector_size {
        interaction_vec.push(pk.encrypt(&G1::one()));
    }

    let mut csprng = thread_rng();
    // let rnd = csprng.gen_range(0, 100000);
    let rnd = 13;
    let rnd: String = rnd.to_string();
    let client_id = "client_id".to_string() + &rnd;

    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("900000").unwrap());
    // opts.gas = Some(web3::types::U256::from_dec_str("100000000").unwrap());
    //
    let tx_receipt = request_reward_computation(
        service.clone(),
        client_id.clone(),
        pk,
        interaction_vec.clone(),
        opts,
    );

    // fail if error
    tx_receipt.unwrap();

    // #TODO: replace with try-fail-try-again pattern
    use std::{thread, time};
    thread::sleep(time::Duration::from_secs(2));

    let result = fetch_aggregate_storage(
        service, client_id.clone(), Options::default());

    //println!("{:?}", result);

    let tuple = match result {
        Ok(r) => r,
        Err(e) => {
            println!("Error fetching aggregate storage: {:?}", e);
            process::exit(0x1000);
        }
    };

    let encrypted_point: CiphertextSolidity = [tuple[0], tuple[1], tuple[2], tuple[3]];
    let encrypted_encoded = match utils::decode_ciphertext(encrypted_point, pk) {
        Ok(r) => r,
        Err(e) => {
            println!("Error decoding ciphertext: {:?}", e);
            process::exit(0x1000);
        }
    };

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
    let _scalar_aggregate = match utils::recover_scalar(decrypted_aggregate, 16) {
        Ok(r) => r,
        Err(e) => {
            println!("Error decrypting aggregate: {:?}", e);
            process::exit(0x1000);
        }
    };

    assert_eq!(_scalar_aggregate, Fr::from_str("3").unwrap()); // 2ads
    // assert_eq!(_scalar_aggregate, Fr::from_str("17").unwrap()); // 16 ads
    //assert_eq!(_scalar_aggregate, Fr::from_str("60").unwrap()); // 128 ads

    println!("Time elapsed: {:?} ({:?})", start_ts.elapsed(), client_id);
    //print!("{:?}, ", start_ts.elapsed().unwrap());
}

