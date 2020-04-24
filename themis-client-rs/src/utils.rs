extern crate primitive_types;

use elgamal_bn::ciphertext::Ciphertext;

pub type EncryptedInteractions = Vec<Vec<Vec<String>>>;

pub fn encode_input_ciphertext(input: Vec<Ciphertext>) -> EncryptedInteractions {
    let encoded_input: Vec<Vec<Vec<String>>> = input
        .into_iter()
        .map(|x| {
            let ((x0, x1), (y0, y1)) = x.get_points_hex_string();
            vec![vec![x0, x1], vec![y0, y1]]
        })
        .collect();
    encoded_input
}
