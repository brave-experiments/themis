#![allow(dead_code)]

pub mod rpc;
mod utils;

use bn::{Group, G1};
use elgamal_bn::private::SecretKey;
use elgamal_bn::public::PublicKey;

use rand::thread_rng;

fn round_one() {
    // crypto
    let (_, pk) = generate_keys();

    // get and encrypt values to send to smart contract
    // for now, it generate points randomly, eventually it will be user inputs
    let mut csprng = thread_rng();
    let interaction_vec = vec![
        pk.encrypt(&G1::random(&mut csprng)),
        pk.encrypt(&G1::random(&mut csprng)),
    ];
    let (_a, _b) = interaction_vec[0].get_points_hex_string();
    //let _encoded_input = utils::to_fixed_array(&a.0, &a.1, &b.0, &b.1);
}

// generate_keys() generates a pair of new {public, private} keys
fn generate_keys() -> (SecretKey, PublicKey) {
    let mut csprng = thread_rng();
    let sk = SecretKey::new(&mut csprng);
    let pk = PublicKey::from(&sk);
    (sk, pk)
}
