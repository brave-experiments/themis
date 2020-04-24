extern crate themis_client;

use themis_client::rpc::SideChainService;

#[test]
fn test_request_reward_computation() {
    let side_chain_addr = "http://18.222.161.183:22000".to_string();
    let account_addr = "0xe64B1F131301662B7d27444c2EffA22815Ef1558".to_string();
    let contract_addr = "83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd".to_string();

    let service = SideChainService::new(side_chain_addr, account_addr, contract_addr);

    let accounts_addr = service.update_accounts_addrs();
    assert_eq!(accounts_addr[0].to_string(), "0xf81c…921d".to_string());
}
