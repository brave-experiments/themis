#![allow(dead_code)]
use std::cell::RefCell;
use std::vec::Vec;

use web3::contract::tokens::Tokenize;
use web3::contract::{Contract, Options};
use web3::futures::Future;
use web3::types::Address;

#[derive(Debug)]
pub struct SideChainService<T: web3::Transport> {
    pub contract: Contract<T>,
    side_chain_addr: String,
    account_addr: String,
    contract_addr: String,
    node_account_addrs: RefCell<Vec<Address>>,
}

impl SideChainService<web3::transports::Http> {
    // Returns a  new side_chain service
    pub fn new(side_chain_addr: String, account_addr: String, contract_addr: String) -> Self {
        let (_eloop, transport) = web3::transports::Http::new(&side_chain_addr).unwrap();
        let web3client = web3::Web3::new(transport);

        let contract_address: Address = contract_addr.parse().unwrap();
        let contract = Contract::from_json(
            web3client.eth(),
            contract_address,
            // TODO: refactor
            include_bytes!("../build/ThemisPolicyContract.abi"),
        )
        .unwrap();

        let node_account_addrs: RefCell<Vec<Address>> = RefCell::new(vec![]);

        SideChainService {
            side_chain_addr,
            account_addr,
            contract_addr,
            contract,
            node_account_addrs,
        }
    }

    pub fn update_accounts_addrs(&self) -> Vec<web3::types::H160> {
        // sets up connection to sidechain using HTTP transport
        let (_eloop, transport) = web3::transports::Http::new(&self.side_chain_addr).unwrap();
        let web3client = web3::Web3::new(transport);

        let accounts = web3client.eth().accounts().wait().unwrap();
        self.node_account_addrs.replace(accounts.clone());
        accounts
    }

    pub fn call_function_remote<T>(
        &self,
        function_name: String,
        input: T,
        opts: Options,
    ) -> Result<String, ()>
    where
        T: Tokenize,
    {
        let result = self
            .contract
            .call(
                &function_name,
                input,
                self.node_account_addrs.borrow()[0],
                opts,
            )
            .wait()
            .unwrap();

        Ok(result.to_string())
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_constructors() {
        let side_chain_addr = "https://test.com".to_string();
        let account_addr = "0xe64B1F131301662B7d27444c2EffA22815Ef1558".to_string();
        let contract_addr = "83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd".to_string();

        let _service = SideChainService::new(side_chain_addr, account_addr, contract_addr);

        //assert!(service.is_ok());
    }
}
