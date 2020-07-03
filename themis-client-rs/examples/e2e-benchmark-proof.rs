extern crate themis_client;

use std::time::SystemTime;
use std::{env, process};
use rand::thread_rng;
use rand::Rng;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use bn::{Fr, Group, G1};

fn main() {
    let side_chain_addr =  match env::var("SIDECHAIN_ADDR") {
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

    //let contract_abi = include_bytes!["../build/ThemisPolicyContract.abi"];
    //let contract_abi = include_bytes!["../build/ThemisPolicyContract_16ads.abi"];
    let contract_abi = include_bytes!["../build/ThemisPolicyContract_128ads.abi"];

    // start counting time
    let start_ts = SystemTime::now();

    let service = SideChainService::new(
        side_chain_addr.clone(), contract_addr.clone(), contract_abi).unwrap();

    let (sk, pk) = generate_keys();

    // generate interaction vector with `policy_vector_size` entries
    //let policy_vector_size = 2;
    //let policy_vector_size = 16;
    let policy_vector_size = 128;
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
        opts.clone(),
    );

    // fail if error
    tx_receipt.unwrap();

    use std::{thread, time};
    let delay = 10;
    thread::sleep(time::Duration::from_secs(delay));

    let result = fetch_aggregate_storage(
        service.clone(), client_id.clone(), Options::default());

    let tuple = match result {
        Ok(r) => r, 
        Err(_e) => { 
            println!("Error fetch_aggregate_storage: {:?}", _e);
            println!(" # ");
            process::exit(0x1000);
        }
    };

    let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];
    let encrypted_encoded = match utils::decode_ciphertext(encrypted_point, pk) {
        Ok(r) => r,
        Err(_e) => { 
            println!("Error decode_ciphertext: {:?}", _e);
            println!(" # ");
            process::exit(0x1000);
        }
    };

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
    let scalar_aggregate = match utils::recover_scalar(decrypted_aggregate, 16) {
        Ok(r) => r,
        Err(_e) => { 
            println!("Error recover_scalar: {:?}", _e);
            println!(" # ");
            process::exit(0x1000);
        }
    };

    let proof_dec = match sk
        .proof_decryption_as_string(&encrypted_encoded, &decrypted_aggregate) {
            Ok(r) => r,
            Err(_e) => { 
                println!("Error proof_decryption_as_string: {:?}", _e);
                println!(" # ");
                process::exit(0x1000);
            }
        };

    let tx_receipt_proof = submit_proof_decryption(&service, &client_id, &proof_dec, &opts);
    assert!(!tx_receipt_proof.is_err());

    let _proof_result = match fetch_proof_verification(&service, &client_id, &Options::default()) {
        Ok(r) => r,
        Err(_e) => { 
            println!("Error fetch_proof_verification {:?}", _e);
            println!(" # ");
            process::exit(0x1000);
        }
    };

    assert_eq!(_proof_result, true);

    //assert_eq!(_scalar_aggregate, Fr::from_str("3").unwrap()); // 2ads
    //assert_eq!(_scalar_aggregate, Fr::from_str("17").unwrap()); // 16 ads
    assert_eq!(scalar_aggregate, Fr::from_str("60").unwrap()); // 128 ads

    print!("{:?}, ", start_ts.elapsed().unwrap().as_secs_f64() - delay as f64);
}
