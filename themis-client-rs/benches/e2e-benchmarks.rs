#![allow(unused_variables)]
extern crate themis_client;

use themis_client::*;
use themis_client::rpc::*;

use bn::{Group, G1};
use web3::contract::Options;

use std::time::Duration;
use criterion::{criterion_group, criterion_main, Criterion};

static SIDECHAIN_ADDR: &str = "http://54.235.4.109:22000";
static CONTRACT_ADDR: &str = "441004e847a5BB3261f4853b2D5a6291AfDaf39b";

// Run criterion benchmarks
criterion_group!(benches, 
    //first_round_bench,
    end_to_end_bench,
    //decrypt_and_recover_scalar_bech,
    );

criterion_main!(benches);

fn service_factory<'a>() -> SideChainService<'a> {
    let side_chain_addr = SIDECHAIN_ADDR.to_owned();
    let contract_addr = CONTRACT_ADDR.to_owned();
    let contract_abi = include_bytes!["../tests/ThemisPolicyContract_Test.abi"];
    SideChainService::new(side_chain_addr.clone(), contract_addr.clone(), contract_abi).unwrap()
}

pub fn first_round_bench(c: &mut Criterion) {
    let mut group = c.benchmark_group("end_to_end");
    let sample_size: usize = 10;
    group.sample_size(sample_size);

    let service = service_factory();

    group.bench_function("remote: reward request -- 2 policies", |b| {
        b.iter(|| {
        let (sk, pk) = generate_keys();
        let interaction_vec = vec![pk.encrypt(&G1::one()), pk.encrypt(&G1::one())];
        let client_id = "client_id".to_owned();

        let mut opts = Options::default();
        opts.gas = Some(web3::types::U256::from_dec_str("900000").unwrap());

        let tx_receipt = request_reward_computation(
            service.clone(),
            client_id.clone(),
            pk,
            interaction_vec,
            opts,
        );
        })
    });

    group.finish();
}

pub fn end_to_end_bench(c: &mut Criterion) {
    let mut group = c.benchmark_group("end_to_end");

    let time = Duration::new(132, 0);
    group.measurement_time(time);

    let sample_size: usize = 10;
    group.sample_size(sample_size);

    let service = service_factory();

    group.bench_function("remote: end to end -- 2 policies", |b| {
        b.iter(|| {
        let (sk, pk) = generate_keys();
        let interaction_vec = vec![pk.encrypt(&G1::one()), pk.encrypt(&G1::one())];
        let client_id = "client_id".to_owned();

        let mut opts = Options::default();
        opts.gas = Some(web3::types::U256::from_dec_str("900000").unwrap());

        let tx_receipt = request_reward_computation(
            service.clone(),
            client_id.clone(),
            pk,
            interaction_vec,
            opts,
        );

        use std::{thread, time};
        thread::sleep(time::Duration::from_secs(2));

        let tuple = fetch_aggregate_storage(service.clone(), client_id, Options::default())
            .unwrap();
        
        let encrypted_point: CiphertextSolidity = [tuple.0, tuple.1, tuple.2, tuple.3];
        let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk).unwrap();
        let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
        let scalar_aggregate = utils::recover_scalar(decrypted_aggregate, 16).unwrap();
        })
    });

    group.finish();

}
