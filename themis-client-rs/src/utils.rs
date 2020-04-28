extern crate sha2;

use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::public::PublicKey;
use sha2::{Digest, Sha256};
use web3::types::{H256, U256};

use crate::Point;

pub type EncryptedInteractions = Vec<Vec<String>>;

pub fn encode_input_ciphertext(input: Vec<Ciphertext>) -> Result<Vec<Point>, ()> {
    let encoded_input: Vec<Point> = input
        .into_iter()
        .map(|x| {
            let ((x0, x1), (y0, y1)) = x.get_points_hex_string();
            let point: Point = [
                serde_json::from_str(&format![r#""{}""#, x0]).unwrap(),
                serde_json::from_str(&format![r#""{}""#, x1]).unwrap(),
                serde_json::from_str(&format![r#""{}""#, y0]).unwrap(),
                serde_json::from_str(&format![r#""{}""#, y1]).unwrap(),
            ];
            point
        })
        .collect();
    Ok(encoded_input)
}

pub fn encode_client_id(client_id: String) -> H256 {
    let mut hasher = Sha256::new();
    hasher.input(client_id);
    H256::from_slice(&hasher.result()[..])
}

pub fn decode_ciphertext(
    raw_point: Point, 
    pk: PublicKey
) -> Result<Ciphertext, ()> {

    println!("{}", format!["0x{}", raw_point[0].to_string()]);
    println!("{}", format!["0x{}", raw_point[0].to_string()].len());

    let encrypted_encoded = Ciphertext::from_hex_string((
        (format!["0x{}", raw_point[0].to_string()], 
         format!["0x{}", raw_point[1].to_string()]), 
        (format!["0x{}", raw_point[2].to_string()], 
         format!["0x{}", raw_point[3].to_string()])
        ), pk
     );

     Ok(encrypted_encoded.unwrap()) // TODO: remove unwrap when error is public in bn crate
}
