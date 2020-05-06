#![allow(dead_code)]
use crate::Error;

use web3::contract::tokens::Tokenize;
use web3::contract::{Contract, Options};
use web3::futures::Future;
use web3::types::{Address, U256};

#[derive(Debug, Clone)]
pub struct SideChainService<'a> {
    side_chain_addr: String,
    contract_addr: Address,
    accounts: Vec<Address>,
    contract_abi: &'a [u8],
}

impl<'a> SideChainService<'a> {
    pub fn new(
        side_chain_addr: String,
        contract_addr: String,
        contract_abi: &'a [u8],
    ) -> Result<Self, Error> {
        let (_eloop, transport) = web3::transports::Http::new(&side_chain_addr)?;
        let web3client = web3::Web3::new(transport);
        let accounts = web3client.eth().accounts().wait()?;

        let contract_addr: Address = contract_addr.parse()?;
        Ok(SideChainService {
            side_chain_addr,
            contract_addr,
            contract_abi,
            accounts,
        })
    }

    pub fn call_function_remote<T>(
        &self,
        function_name: String,
        input: T,
        opts: Options,
    ) -> Result<String, Error>
    where
        T: Tokenize,
    {
        let (_eloop, transport) = web3::transports::Http::new(&self.side_chain_addr)?;
        let web3client = web3::Web3::new(transport);

        let contract =
            match Contract::from_json(web3client.eth(), self.contract_addr, &self.contract_abi) {
                Ok(c) => c,
                Err(_) => return Err(Error::EthAbiErrorSerdeJson {}),
            };

        let result = contract
            .call(&function_name, input, self.accounts[0], opts)
            .wait()?;

        Ok(result.to_string())
    }

    // todo: refactor and merge with either the above or below
    pub fn query_bool_function_remote<T>(
        &self,
        function_name: &String,
        input: T,
        opts: &Options,
    ) -> Result<bool, Error>
    where
        T: Tokenize,
    {
        let (_eloop, transport) = web3::transports::Http::new(&self.side_chain_addr)?;
        let web3client = web3::Web3::new(transport);

        let contract =
            match Contract::from_json(web3client.eth(), self.contract_addr, &self.contract_abi) {
                Ok(c) => c,
                Err(_e) => return Err(Error::EthAbiErrorSerdeJson {}),
            };

        let check: bool = contract
            .query(
                &function_name,
                input,
                self.accounts[0].clone(),
                opts.clone(),
                None,
            )
            .wait()?;

        Ok(check)
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
        let (_eloop, transport) = web3::transports::Http::new(&self.side_chain_addr)?;
        let web3client = web3::Web3::new(transport);

        let contract =
            match Contract::from_json(web3client.eth(), self.contract_addr, &self.contract_abi) {
                Ok(c) => c,
                Err(_) => return Err(Error::EthAbiErrorSerdeJson {}),
            };

        let points: (U256, U256, U256, U256) = contract
            .query(&function_name, input, self.accounts[0], opts, None)
            .wait()?;

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
        let abi = include_bytes!["../build/ThemisPolicyContract.abi"];

        let _service = SideChainService::new(side_chain_addr, contract_addr, abi);
        //assert!(service.is_ok());
    }
}
