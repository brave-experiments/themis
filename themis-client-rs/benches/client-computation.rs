#[macro_use]
extern crate criterion;
use criterion::Criterion;
use themis_client::{generate_keys, utils};
use rand::Rng;
use bn::{Group, Fr, G1};
use elgamal_bn::ciphertext::Ciphertext;

fn create_encrypt_overhead_helper(size_catalog: usize, c: &mut Criterion) {
    let label = format!("Client overhead encrypting a catalog of {} ads", size_catalog);

    c.bench_function(
        &label,
        move |b| {
            let (_, pk) = generate_keys();

            // generates interactions
            let mut interaction_vec = vec![];
            for _i in 0..size_catalog {
                let rnd = G1::one() * Fr::from_str("17").unwrap();
                interaction_vec.push(rnd);
            }

            b.iter(|| {
                // Encrypt interactions
                let _encrypted_interaction: Vec<Ciphertext> = interaction_vec.clone().into_iter().map(|x| {
                    pk.encrypt(&x)
                }).collect();
            })
        }
    );
}

fn create_encrypted_vector_64(c: &mut Criterion) {
    create_encrypt_overhead_helper(64, c);
}

fn create_encrypted_vector_128(c: &mut Criterion) {
    create_encrypt_overhead_helper(128, c);
}

fn create_encrypted_vector_256(c: &mut Criterion) {
    create_encrypt_overhead_helper(256, c);
}

fn create_decrypt_overhead_helper(size_catalog: usize, c: &mut Criterion) {
    let label = format!("Client overhead decrypting a catalog of {} ads", size_catalog);

    c.bench_function(
        &label,
        move |b| {
            let (sk, pk) = generate_keys();
            let mut rng = rand::thread_rng();

            // generates interactions
            let mut interaction_vec = vec![];
            for _ in 0..size_catalog {
                let rnd = rng.gen_range(0, 30);
                let rnd_str: String = rnd.to_string();
                let rnd_fr = Fr::from_str(&rnd_str).unwrap();
                let r = G1::one() * rnd_fr;
                interaction_vec.push(r);
            }

            // generates random policy
            let mut policy_vec = vec![];
            for _ in 0..size_catalog {
                let rnd = rng.gen_range(0, 30);
                let rnd_str: String = rnd.to_string();
                let rnd_fr = Fr::from_str(&rnd_str).unwrap();
                policy_vec.push(rnd_fr);
            }

            // generates aggregate
            let pairwise_prod: Vec<G1> = interaction_vec
                .into_iter()
                .zip(policy_vec.into_iter())
                .map(|(x, y)| {
                    x * y
                }).collect();
            let mut aggregate = pairwise_prod[0];
            for &i in pairwise_prod[1..].iter() {
                aggregate = aggregate + i;
            }

            let encrypted_aggregate = pk.encrypt(&aggregate);

            b.iter(|| {
                // Decrypt interactions
                let decrypted_aggregate: G1 = sk.decrypt(&encrypted_aggregate);

                // Prove correctness
                let proof_decryption = sk.proof_decryption_as_string(
                    &encrypted_aggregate,
                    &decrypted_aggregate
                );

                // Extract reward from point
                let _scalar_reward = utils::recover_scalar(decrypted_aggregate, 16).unwrap();

            })
        }
    );
}

fn create_decrypted_vector_64(c: &mut Criterion) {
    create_decrypt_overhead_helper(64, c);
}

fn create_decrypted_vector_128(c: &mut Criterion) {
    create_decrypt_overhead_helper(128, c);
}

fn create_decrypted_vector_256(c: &mut Criterion) {
    create_decrypt_overhead_helper(256, c);
}

criterion_group! {
    name = encrypt_interactions;
    config = Criterion::default().sample_size(10);
    targets =
    create_encrypted_vector_64,
    create_encrypted_vector_128,
    create_encrypted_vector_256
}

criterion_group! {
    name = decrypt_interactions;
    config = Criterion::default().sample_size(10);
    targets =
    create_decrypted_vector_64,
    create_decrypted_vector_128,
    create_decrypted_vector_256
}

criterion_main!(encrypt_interactions, decrypt_interactions);