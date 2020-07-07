extern crate themis_client;

use themis_client::rpc::*;
use themis_client::*;

use web3::contract::Options;

use bn::{Fr, Group, G1};
use elgamal_bn::ciphertext::Ciphertext;
use rand::{thread_rng, Rng};

fn main() {
    let side_chain_addr = "http://127.0.0.1:9545".to_owned();
    let contract_addr = "99eAa0Bd2069837CF0590931f3f1d92465dD6e00".to_owned();
    let contract_abi = include_bytes!["../build/ThemisPolicyContract.abi"];

    let service =
        SideChainService::new(side_chain_addr.clone(), contract_addr.clone(), contract_abi)
            .unwrap();

    let (sk, pk) = generate_keys();
    let ctxt_one = pk.encrypt(&G1::one());

    let policy_length = 16;

    //let mut csprng = thread_rng();
    let interaction_vec = vec![ctxt_one.clone(); 512];

    let mut csprng = thread_rng();
    // let rnd = csprng.gen_range(0, 100000);
    let rnd = 4;
    let rnd: String = rnd.to_string();
    let client_id = "client_id".to_string() + &rnd;
    let mut opts = Options::default();
    opts.gas = Some(web3::types::U256::from_dec_str("3000000").unwrap());

    let tx_receipt = request_reward_computation(
        service.clone(),
        client_id.clone(),
        pk,
        interaction_vec.clone(),
        opts.clone(),
    );

    // assert!(!tx_receipt.is_err());
    tx_receipt.unwrap();

    let result = fetch_aggregate_storage(service.clone(), client_id.clone(), Options::default());

    assert!(!result.is_err());
    let tuple = result.unwrap();

    let encrypted_point: CiphertextSolidity = [tuple[0], tuple[1], tuple[2], tuple[3]];

    // TODO: refactor to utils
    let encrypted_encoded = utils::decode_ciphertext(encrypted_point, pk);
    // assert!(!encrypted_encoded.is_err());

    let encrypted_encoded = encrypted_encoded.unwrap();

    let decrypted_aggregate = sk.decrypt(&encrypted_encoded);
    let expected_aggregate = G1::one() * Fr::from_str("17").unwrap();

    assert_eq!(decrypted_aggregate, expected_aggregate,);

    let proof_dec = sk
        .proof_decryption_as_string(&encrypted_encoded, &decrypted_aggregate)
        .unwrap();

    let tx_receipt_proof = submit_proof_decryption(&service, &client_id, &proof_dec, &opts);

    assert!(!tx_receipt_proof.is_err());

    let proof_result = fetch_proof_verification(&service, &client_id, &Options::default()).unwrap();

    assert!(proof_result);
}
