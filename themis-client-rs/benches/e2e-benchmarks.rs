#![allow(unused_variables)]
extern crate themis_client;

use rand::Rng;

use themis_client::*;
use themis_client::rpc::*;

use bn::{Group, G1, Fr};
use web3::contract::Options;

use criterion::{criterion_group, criterion_main, Criterion};

use std::time::Duration;

pub const POLICY_VECTOR_SIZE: i32 = 128;

static SIDECHAIN_ADDR: &str = "http://34.227.11.190:22000";
//static CONTRACT_ADDR: &str = "C9363C51bE4eeE9B892EA612F3d5D448a6E56436"; // 64 ads
static CONTRACT_ADDR: &str = "13833797A938B4E9D6F1B7B4E3517FC660DA7533"; // 128 ads
//static CONTRACT_ADDR: &str = "B6e358f59D269E54A264001A2E87f3BF44dbA673"; // 256 ads

// Run criterion benchmarks
criterion_group!(benches,
    all_benches,
    // all_benches_dry_run,
);

criterion_main!(benches);

// end to end with sidechain interaction
pub fn all_benches(c: &mut Criterion) {
    let mut group = c.benchmark_group("client_side");
    let sample_size: usize = 10;
    let time = Duration::new(40, 0);
    group.sample_size(sample_size);
    group.measurement_time(time);
    
    //let service = service_factory();
    let policy_vector_size = POLICY_VECTOR_SIZE;

    //let contract_abi = include_bytes!["../build/ThemisPolicyContract_64ads.abi"];
    let contract_abi = include_bytes!["../build/ThemisPolicyContract_128ads.abi"];
    //let contract_abi = include_bytes!["../build/ThemisPolicyContract_256ads.abi"];

    let service = SideChainService::new(
        SIDECHAIN_ADDR.to_owned(),
        CONTRACT_ADDR.to_owned(),
        contract_abi,   
    ).unwrap();

    // generate keys (needs to be accessible to both 1. and 2. benches' scopes)
    let (sk, pk) = generate_keys();

    // generates random interactions
    let mut rng = rand::thread_rng();
    let mut interaction_vec_dec = vec![];
    for _i in 0..policy_vector_size {
        let rnd = rng.gen_range(0, 10);
        let rnd_str: String = rnd.to_string();
        interaction_vec_dec.push(rnd_str);
    }
    let rnd = rng.gen_range(0, 100000);
    let rnd: String = rnd.to_string();
    let client_id = "client_id".to_owned() + &rnd;
    
    let mut interaction_vec = vec![];

    group.bench_function(format!("1. reward request {} ads catalog", policy_vector_size), |b| {
        b.iter(|| {
 
        // encrypts interactions
        interaction_vec_dec.clone().into_iter().map(|x| {
            let rnd_fr = Fr::from_str(&x).unwrap();
            let r = G1::one() * rnd_fr;
            interaction_vec.push(r);
        });
     
        // encrypt interactions
        let interactions_vec = interaction_vec.clone().into_iter().map(|x| {
            pk.encrypt(&x)
        }).collect();

        let mut opts = Options::default();
        opts.gas = Some(web3::types::U256::from_dec_str("30000000").unwrap());

        // calls smart contract
        let tx_receipt = request_reward_computation(
            service.clone(),
            client_id.clone(),
            pk,
            interactions_vec,
            opts,
        );

        tx_receipt.unwrap();
        })
    });

    use std::{thread, time};
    thread::sleep(time::Duration::from_secs(20));

    group.bench_function(format!("2. fetch encrypted aggregate, decrypt aggregate, recover scalar ({} ads)", 
        policy_vector_size), |b| {
            b.iter(|| {
                let result = fetch_aggregate_storage(
                    service.clone(), client_id.clone(), Options::default());
                let tuple = result.unwrap();
                print!("{:?}", tuple);

                let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];
                let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk).unwrap();
                let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
                let _scalar_aggregate = utils::recover_scalar(decrypted_aggregate, 16).unwrap();
            })
    });

    group.finish();
}

// // end to end without sidechain interaction
// pub fn all_benches_dry_run(c: &mut Criterion) {
//     let mut group = c.benchmark_group("client_side_dry_run");
//     let sample_size: usize = 10;
//     let time = Duration::new(40, 0);
//     group.sample_size(sample_size);
//     group.measurement_time(time);
//
//     //let service = service_factory();
//     let policy_vector_size = POLICY_VECTOR_SIZE;
//
//     //let contract_abi = include_bytes!["../build/ThemisPolicyContract_64ads.abi"];
//     let contract_abi = include_bytes!["../build/ThemisPolicyContract_128ads.abi"];
//     //let contract_abi = include_bytes!["../build/ThemisPolicyContract_256ads.abi"];
//
//     let service = SideChainService::new(
//         SIDECHAIN_ADDR.to_owned(),
//         CONTRACT_ADDR.to_owned(),
//         contract_abi,
//     ).unwrap();
//
//     // generate keys (needs to be accessible to both 1. and 2. benches' scopes)
//     let (sk, pk) = generate_keys();
//
//     // generates random interactions
//     let mut rng = rand::thread_rng();
//     let mut interaction_vec_dec = vec![];
//     for _i in 0..policy_vector_size {
//         let rnd = rng.gen_range(0, 10);
//         let rnd_str: String = rnd.to_string();
//         interaction_vec_dec.push(rnd_str);
//     }
//     let rnd = rng.gen_range(0, 100000);
//     let rnd: String = rnd.to_string();
//     let client_id = "client_id".to_owned() + &rnd;
//
//     let mut interaction_vec = vec![];
//
//     group.bench_function(format!("1. prepare reward request {} ads catalog", policy_vector_size), |b| {
//         b.iter(|| {
//
//         // encrypts interactions
//         interaction_vec_dec.clone().into_iter().map(|x| {
//             let rnd_fr = Fr::from_str(&x).unwrap();
//             let r = G1::one() * rnd_fr;
//             interaction_vec.push(r);
//         });
//
//         // encrypt interactions
//         let interactions_vec = interaction_vec.clone().into_iter().map(|x| {
//             pk.encrypt(&x)
//         }).collect();
//
//
//        })
//     });
//
//     // get/calculate tuple
//     let tuple = (0, 0, 0, 0);
//
//     group.bench_function(format!("2. decode and decrypt aggregate, recover scalar ({} ads)",
//         policy_vector_size), |b| {
//             b.iter(|| {
//
//                 let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];
//                 let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk).unwrap();
//                 let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
//                 let _scalar_aggregate = utils::recover_scalar(decrypted_aggregate, 16).unwrap();
//             })
//     });
//
//     group.finish();
//
//
// }

