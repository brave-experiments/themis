#![allow(unused_variables)]
extern crate themis_client;

use rand::Rng;

use themis_client::*;
use themis_client::rpc::*;

use bn::{Group, G1, Fr};
use web3::contract::Options;

use criterion::{criterion_group, criterion_main, Criterion};

static SIDECHAIN_ADDR: &str = "http://54.235.4.109:22000";
static CONTRACT_ADDR: &str = "fD3d8240Ea51CC57dBBf0b7783E6e484B7Fbb23a"; // 128 ads

// Run criterion benchmarks
criterion_group!(benches, 
    first_round_bench,
    //decrypt_and_recover_bench,
    );

criterion_main!(benches);

fn service_factory<'a>() -> SideChainService<'a> {
    let side_chain_addr = SIDECHAIN_ADDR.to_owned();
    let contract_addr = CONTRACT_ADDR.to_owned();
    let contract_abi = include_bytes!["../build/ThemisPolicyContract_128ads.abi"];
    SideChainService::new(side_chain_addr.clone(), contract_addr.clone(), contract_abi).unwrap()
}

// first_round_bench benchmarks the time and resources required in the client side 
// for generating the key pais, encrypting a 128 ads vector and call the smart
// contract
pub fn first_round_bench(c: &mut Criterion) {
    let mut group = c.benchmark_group("client_side");
    let sample_size: usize = 10;
    group.sample_size(sample_size);

    //let time = Duration::new(70, 0);
    //group.measurement_time(time);
    
    let service = service_factory();
    let policy_vector_size = 128;

    // generates random interactions
    let mut rng = rand::thread_rng();
    let mut interaction_vec_dec = vec![];
    for _i in 0..policy_vector_size {
        let rnd = rng.gen_range(0, 10);
        let rnd_str: String = rnd.to_string();
        let rnd_fr = Fr::from_str(&rnd_str).unwrap();
        let r = G1::one() * rnd_fr;
        interaction_vec_dec.push(r);
    }

    let rnd = rng.gen_range(0, 100000);
    let rnd: String = rnd.to_string();
    let client_id = "client_id".to_owned() + &rnd;

    group.bench_function("1. reward request (128 ads catalog)", |b| {
        b.iter(|| {
        
        // generate keys
        let (sk, pk) = generate_keys();

        // encrypt interactions
        let interactions_vec = interaction_vec_dec.clone().into_iter().map(|x| {
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
        })
    });

    group.finish();
}

pub fn decrypt_and_recover_bench(c: &mut Criterion) {
    let mut group = c.benchmark_group("client_side");
    let sample_size: usize = 10;
    group.sample_size(sample_size);

    //let time = Duration::new(70, 0);
    //group.measurement_time(time);
    
    let service = service_factory();
    let policy_vector_size = 128;

    let mut rng = rand::thread_rng();

    let (sk, pk) = generate_keys();
    let rnd = rng.gen_range(0, 100000);
    let rnd: String = rnd.to_string();
    let client_id = "client_id".to_owned() + &rnd;

    // generates and encrypts random interactions
    let mut interaction_vec = vec![];
    for _i in 0..policy_vector_size {
        let rnd = rng.gen_range(0, 10);
        let rnd_str: String = rnd.to_string();
        let rnd_fr = Fr::from_str(&rnd_str).unwrap();
        let r = G1::one() * rnd_fr;
        interaction_vec.push(pk.encrypt(&r));
    }

    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("30000000").unwrap());

    let tx_receipt = request_reward_computation(
        service.clone(),
        client_id.clone(),
        pk,
        interaction_vec,
        opts,
    );

    use std::{thread, time};
    thread::sleep(time::Duration::from_secs(5));

    group.bench_function("2. fetch encrypted aggregate, decrypt aggregate, recover scalar (128 ads)", |b| {
        b.iter(|| {
            let result = fetch_aggregate_storage(
                service.clone(), client_id.clone(), Options::default());
            let tuple = result.unwrap(); 
            let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];
            let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk).unwrap();
            let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
            let _scalar_aggregate = utils::recover_scalar(decrypted_aggregate, 16).unwrap();
        })
    });

    group.finish();
}
