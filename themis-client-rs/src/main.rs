extern crate bn;
extern crate ethabi;
extern crate primitive_types;
extern crate rand;
extern crate web3;
use bn::{pairing, Fr, Group, G1, G2};

use ethabi::Token::{FixedArray, FixedBytes};
use ethabi::*;
use primitive_types::*;
use web3::contract::{Contract, Options};
use web3::futures::Future;
use web3::types::Address;

fn main() {

    // let (alice_pk1, alice_pk2) = (G1::one() * sk ,G2::one() * sk);
    // print!("{:?},{:?}",alice_pk1,alice_pk2 );
    // let addr = "http://18.224.69.120:22000";
    // let _smart_contract_addr = "0x83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd";

    // let (_eloop, transport) = web3::transports::Http::new(&addr).unwrap();

    // let web3 = web3::Web3::new(transport);

    // // Accessing account
    // let accounts = web3.eth().accounts().wait().unwrap();

    // // Accessing existing contract
    // let contract_address: Address = "83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd".parse().unwrap();
    // let contract = Contract::from_json(
    //     web3.eth(),
    //     contract_address,
    //     include_bytes!("../build/ThemisPolicyContract.abi"),
    // )
    // .unwrap();

    // let vector = to_fixed_array(
    //     "1368015179489954701390400359078579693043519447331113978918064868415326638035",
    //     "9918110051302171585080402603319702774565515993150576347155970296011118125764",
    //     "4503322228978077916651710446042370109107355802721800704639343137502100212473",
    //     "6132642251294427119375180147349983541569387941788025780665104001559216576968",
    // );

    // let client_id = FixedBytes(vec![1, 2]);

    // let result = contract.call(
    //     "calculate_aggregate",
    //     (vector, client_id),
    //     accounts[0],
    //     Options::default(),
    // );
    // let aggregate = result.wait().unwrap();
    // println!("aggregate: {:?}", aggregate);
}
//
fn to_fixed_array(input1: &str, input2: &str, input3: &str, input4: &str) -> ethabi::Token {
    let in_array = vec![input1, input2, input3, input4];

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

// function encrypt(plaintext, pubkey) {
// 	let rndScalar = bn128.randomGroupScalar();
// 	let x = rndScalar // TODO: change for (rndScalar * G)

// 	let y_tmp = pubkey[0].mul(rndScalar);
// 	let y = plaintext.add(y_tmp);

// 	return [x, y];
//   }

fn generate_keypair() -> (Fr, G1) {
    let rng = &mut rand::thread_rng();
    let sk = Fr::random(rng);
    let pk = G1::one() * sk;
    let key = (sk, pk);
    return key;
}

// fn encrypt(plaintext:) -> {
// 	let plaintext =  String::From('11111');
// 	let rand_scalar =
// }
