extern crate bigint;
extern crate bincode;
extern crate ethabi;
extern crate hex;
extern crate primitive_types;
extern crate web3;

use ethabi::Token::{FixedArray, FixedBytes, Uint};
use ethabi::*;
use primitive_types::*;
use web3::contract::{Contract, Options};
use web3::futures::Future;
use web3::types::{Address, Bytes, H256 as H256_w, U256 as U256_w};



// TODO: remove main(), only for testing!
fn main() {
    let addr = "http://18.224.69.120:22000";
    let smart_contract_addr = "0x83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd";

    // let result = request_calculation(
    // 	addr.to_string(),
    // 	smart_contract_addr.to_string(),
    // 	"".to_string(),
    // 	"".to_string(),
    // 	"".to_string(),
    // );

    // println!(">> account: {:?}", result.unwrap());

    let (_eloop, transport) = web3::transports::Http::new(&addr).unwrap();

    let web3 = web3::Web3::new(transport);
    let accounts = web3.eth().accounts().wait().unwrap();

    // Accessing existing contract
    let accounts = web3.eth().accounts().wait().unwrap();

    let contract_address: Address = "83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd".parse().unwrap();
    let contract = Contract::from_json(
        web3.eth(),
        contract_address,
        include_bytes!("../build/ThemisPolicyContract.abi"),
    )
    .unwrap();

    let a = Token::Uint(
        U256::from_dec_str(
            "1368015179489954701390400359078579693043519447331113978918064868415326638035",
        )
        .unwrap(),
    );
    let b = Token::Uint(
        U256::from_dec_str(
            "9918110051302171585080402603319702774565515993150576347155970296011118125764",
        )
        .unwrap(),
    );
    let c = Token::Uint(
        U256::from_dec_str(
            "4503322228978077916651710446042370109107355802721800704639343137502100212473",
        )
        .unwrap(),
    );
    let d = Token::Uint(
        U256::from_dec_str(
            "6132642251294427119375180147349983541569387941788025780665104001559216576968",
        )
        .unwrap(),
    );

    let f = vec![c, d];
    let g = vec![a,b];
    let x = FixedArray(f); /*Desired Type: https://docs.rs/ethabi/12.0.0/ethabi/enum.Token.html#method.to_array*/ 
  
	let n = Bytes::from("0xdf32340000000000000000000000000000000000000000000000000000000000");
	let result = contract.call(
        "calculate_aggregate",
        (x),
        accounts[0],
        Options::default(),
    );
    let aggregate = result.wait().unwrap();
	println!("{}", aggregate);
   
	/*

	Error:  the trait `web3::contract::tokens::Tokenizable` is not implemented for `ethabi::Token`
	When strings are used; thread 'main' panicked at 'called `Result::unwrap()` on an `Err` value: Abi(InvalidData)', src/main.rs:115:21 
	*/

}