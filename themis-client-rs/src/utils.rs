extern crate sha2;

use crate::errors::Error;

use bn::{Group, G1, Fr};
use elgamal_bn::ciphertext::Ciphertext;
use elgamal_bn::public::PublicKey;
use sha2::{Digest, Sha256};

use web3::types::H256;
use web3::contract::Options;

use crate::{Point, Proof};

pub type EncryptedInteractions = Vec<Vec<String>>;

// pub fn encode_proof_decryption(announcement: &G1, response: &Fq) -> Result<Proof, ()> {
//     let encoded_input: Proof =
// }

// TODO: Handle unwrap() embeeded in the map()
pub fn encode_input_ciphertext(input: Vec<Ciphertext>) -> Result<Vec<Point>, Error> {
    let encoded_input: Vec<Point> = input
        .into_iter()
        .map(|x| {
            let ((x0, x1), (y0, y1)) = x.get_points_hex_string().unwrap();
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

pub fn decode_ciphertext(raw_point: Point, pk: PublicKey) -> Result<Ciphertext, Error> {
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

pub fn default_options() -> Options {
    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("900000").unwrap());
    opts
}

// TODO: Handle unwrap() embeeded in the map()
pub fn encrypt_input(input: Vec<u8>, pk: PublicKey) -> Result<Vec<Ciphertext>, Error> {
    let enc_input = input.into_iter().map(|x| {
        let string_input = x.to_string();
        pk.encrypt(&(G1::one() * Fr::from_str(&string_input).unwrap()))
    }).collect();

    Ok(enc_input)
}
