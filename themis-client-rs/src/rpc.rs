#![allow(dead_code)]
use web3::contract::tokens::Tokenize;
use web3::contract::{Contract, Error, Options};
use web3::futures::Future;
use web3::types::{Address, U256};

#[derive(Debug, Clone)]
pub struct SideChainService {
    side_chain_addr: String,
    contract_addr: Address,
    accounts: Vec<Address>,
    contract_abi_path: String,
}

impl SideChainService {
    pub fn new(side_chain_addr: String, contract_addr: String, contract_abi_path: String) -> Self {
        let (_eloop, transport) = web3::transports::Http::new(&side_chain_addr).unwrap();
        let web3client = web3::Web3::new(transport);
        let accounts = web3client.eth().accounts().wait().unwrap();

        let contract_addr: Address = contract_addr.parse().unwrap();
        SideChainService {
            side_chain_addr,
            contract_addr,
            contract_abi_path,
            accounts,
        }
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
        let (_eloop, transport) = web3::transports::Http::new(&self.side_chain_addr).unwrap();
        let web3client = web3::Web3::new(transport);

        let contract = Contract::from_json(
            web3client.eth(),
            self.contract_addr,
            include_bytes!("../build/ThemisPolicyContract.abi"), //REFACTOR
        )
        .unwrap();

        let result = contract
            .call(&function_name, input, self.accounts[0], opts)
            .wait()
            .unwrap();

        Ok(result.to_string())
    }

    // #TODO: refactor and merge with call_function_remote
    pub fn query_function_remote<T>(
        &self,
        function_name: String,
        input: T,
        opts: Options,
    ) -> Result<(U256, U256, U256, U256), Error>
    where
        T: Tokenize,
    {
        let (_eloop, transport) = web3::transports::Http::new(&self.side_chain_addr).unwrap();
        let web3client = web3::Web3::new(transport);

        let contract = Contract::from_json(
            web3client.eth(),
            self.contract_addr,
            include_bytes!("../build/ThemisPolicyContract.abi"), //REFACTOR
        )
        .unwrap();

        let points: (U256, U256, U256, U256) = contract
            .query(&function_name, input, self.accounts[0], opts, None)
            .wait()
            .unwrap();

        Ok(points)
    }
}

#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn test_constructors() {
        let side_chain_addr = "http://127.0.0.1:9545".to_owned();
        let contract_addr = "83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd".to_owned();
        let abi_path = "../build/ThemisPolicyContract.abi".to_owned();

        let _service = SideChainService::new(side_chain_addr, contract_addr, abi_path);
        //assert!(service.is_ok());
    }
}
