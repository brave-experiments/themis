extern crate ethabi;
extern crate primitive_types;
extern crate web3;
extern crate elgamal_bn;

use ethabi::Token::{FixedArray, FixedBytes};
use ethabi::*;
use primitive_types::*;
use web3::contract::{Contract, Options};
use web3::futures::Future;
use web3::types::Address;

use rand::{thread_rng};
use elgamal_bn::public::PublicKey;
use elgamal_bn::private::SecretKey;

use bn::{G1, Group};

fn generate_keys() -> (SecretKey, PublicKey) {
    let mut csprng = thread_rng();
    let sk = SecretKey::new(&mut csprng);
    let pk = PublicKey::from(&sk);
    (sk, pk)
}

fn main() {
    let addr = "http://18.222.161.183:22000";
    let _smart_contract_addr = "0xe64B1F131301662B7d27444c2EffA22815Ef1558";
    let (_eloop, transport) = web3::transports::Http::new(&addr).unwrap();
    let web3 = web3::Web3::new(transport);

    // Accessing account
    let accounts = web3.eth().accounts().wait().unwrap();

    // Accessing existing contract
    let contract_address: Address = "83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd".parse().unwrap();
    let contract = Contract::from_json(
         web3.eth(),
         contract_address,
         include_bytes!("../build/ThemisPolicyContract.abi"),
     )
     .unwrap();

    // crypto
    let (_, pk) = generate_keys();

    // get and encrypt values to send to smart contract
    // for now, it generate points randomly, eventually it will be user inputs
    let mut csprng = thread_rng();
    let interaction_vec = vec![
        pk.encrypt(&G1::random(&mut csprng)),
        pk.encrypt(&G1::random(&mut csprng)),
    ];
    let (a, b) = interaction_vec[0].get_points_string();
    let encoded_input = to_fixed_array(
        &a.0, &a.1,
        &b.0, &b.1,
    );
    let client_id = FixedBytes(vec![1, 2]);

    // calls contract
     let result = contract.call(
         "calculate_aggregate",
         (encoded_input, client_id),
         accounts[0],
         Options::default(),
     );
     let aggregate = result.wait().unwrap();
     println!("aggregate: {:?} Tx", aggregate);
}

fn to_fixed_array(input1: &str, input2: &str, input3: &str, input4: &str) -> ethabi::Token {
    let out_array: Vec<Token> = [input1, input2, input3, input4]
        .iter()
        .map(|&input| Token::Uint(U256::from_dec_str(input).unwrap()))
        .collect();
    // let x = vec![out_array[0].clone(), out_array[1].clone()];
    // let y = vec![out_array[2].clone(), out_array[3].clone()];

    let x = vec![out_array[0].clone(), out_array[1].clone()];
    let y = vec![out_array[2].clone(), out_array[3].clone()];

    let output = FixedArray(vec![FixedArray(x), FixedArray(y)]);
    return output;
}

fn _test_working_vector() ->  ethabi::Token {
    to_fixed_array(
         "1368015179489954701390400359078579693043519447331113978918064868415326638035",
         "9918110051302171585080402603319702774565515993150576347155970296011118125764",
         "4503322228978077916651710446042370109107355802721800704639343137502100212473",
         "6132642251294427119375180147349983541569387941788025780665104001559216576968",
     )
}
