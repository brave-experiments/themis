extern crate sha2;

use crate::errors::Error;

use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::public::PublicKey;
use sha2::{Digest, Sha256};
use web3::types::H256;

use crate::{CiphertextSolidity, Proof, Point};

pub type EncryptedInteractions = Vec<Vec<String>>;

pub fn encode_proof_decryption(input: &[String; 7]) -> Result<Proof, ()> {
    let proof: Proof = [
        serde_json::from_str(&format![r#""{}""#, input[0]]).unwrap(),
        serde_json::from_str(&format![r#""{}""#, input[1]]).unwrap(),
        serde_json::from_str(&format![r#""{}""#, input[2]]).unwrap(),
        serde_json::from_str(&format![r#""{}""#, input[3]]).unwrap(),
        serde_json::from_str(&format![r#""{}""#, input[4]]).unwrap(),
        serde_json::from_str(&format![r#""{}""#, input[5]]).unwrap(),
        serde_json::from_str(&format![r#""{}""#, input[6]]).unwrap(),
    ];
    Ok(proof)
}

pub fn encode_public_key(input: PublicKey) -> Result<Point, Error> {

    let (x, y) = input.get_point_hex_string().unwrap();
    let pk_point: Point = [
        serde_json::from_str(&format![r#""{}""#, x]).unwrap(),
        serde_json::from_str(&format![r#""{}""#, y]).unwrap(),
    ];
    Ok(pk_point)
}

pub fn encode_input_ciphertext(input: Vec<Ciphertext>) -> Result<Vec<CiphertextSolidity>, Error> {
    let encoded_input: Vec<CiphertextSolidity> = input
        .into_iter()
        .map(|x| {
            // todo: handle these unwraps
            let ((x0, x1), (y0, y1)) = x.get_points_hex_string().unwrap();
            let point: CiphertextSolidity = [
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

pub fn decode_ciphertext(raw_point: CiphertextSolidity, pk: PublicKey) -> Result<Ciphertext, Error> {
    let encrypted_encoded = Ciphertext::from_dec_string(
        (
            (raw_point[0].to_string(), raw_point[1].to_string()),
            (raw_point[2].to_string(), raw_point[3].to_string()),
        ),
        pk,
    );

    let encrypted_encoded = match encrypted_encoded {
        Ok(e) => e,
        Err(_) => return Err(Error::ElGamalConversionError{}),
    };
    Ok(encrypted_encoded)
}
