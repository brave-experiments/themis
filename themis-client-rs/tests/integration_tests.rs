extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use bn::{Group, G1};
use rand::thread_rng;

#[test]
fn test_request_reward_computation() {
    let side_chain_addr = "http://18.222.161.183:22000".to_string();
    let account_addr = "0xe64B1F131301662B7d27444c2EffA22815Ef1558".to_string();
    let contract_addr = "83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd".to_string();

    let service = SideChainService::new(side_chain_addr, account_addr, contract_addr);
    service.update_accounts_addrs();

    let (_sk, pk) = generate_keys();

    let mut csprng = thread_rng();
    let interaction_vec = vec![
        pk.encrypt(&G1::random(&mut csprng)),
        pk.encrypt(&G1::random(&mut csprng)),
    ];

    let client_id = "testing".to_string();
    let opts = Options::default();
    let tx_receipt = request_reward_computation(service, client_id, interaction_vec, opts).unwrap();

    assert_eq!(tx_receipt, "".to_string());
}
