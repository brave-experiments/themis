extern crate sha2;

use elgamal_bn::ciphertext::Ciphertext;
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

pub fn encode_input_ciphertext_ok(input: Vec<Ciphertext>) -> Result<Vec<Point>, ()> {
    let encoded_input: Vec<Point> = input
        .into_iter()
        .map(|x| {
            let ((_, _), (_, _)) = x.get_points_hex_string();
            let point: Point = [
                serde_json::from_str(&format![r#""0x{}""#, U256::zero()]).unwrap(),
                serde_json::from_str(&format![r#""0x{}""#, U256::zero()]).unwrap(),
                serde_json::from_str(&format![r#""0x{}""#, U256::zero()]).unwrap(),
                serde_json::from_str(&format![r#""0x{}""#, U256::zero()]).unwrap(),
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
