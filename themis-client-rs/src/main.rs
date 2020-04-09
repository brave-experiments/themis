extern crate web3;

use web3::futures::Future;

// TODO: remove main(), only for testing!
fn main() {

	let addr = "http://18.224.69.120:22000";
	let smart_contract_addr = "0x83249c2366a34cCbe6b2AeFEeF94A59beFc4C4Cd";

	let result = request_calculation(
		addr.to_string(),
		smart_contract_addr.to_string(),
		"".to_string(),
		"".to_string(),
		"".to_string(),
	);

	println!(">> account: {:?}", result.unwrap());
}

// request_rewards_calculation encrypts the elements in the interactions array
// and requests the reward calculation from the sidechain. it returns the
// uniqueID which the request was made with (for later retrieval of the results
// from the smart contract) and tx receipt address
pub fn request_calculation(
	side_chain_addr: String,
	contract_addr: String,
	client_skey_encoded: String,
	interactions_arr_encoded: String,
	smart_contract_addr: String,
) -> Result<(String), (String)> {


	

	// TODO: Note: implement these steps once we have the elgamal_bn256
	// implementation

	// 1) decodes client secret key
	// 2) decodes interactions array
	// 3) encrypts each interaction array element
	// 4) generates unique ID


	// make web3 request (threaded)
	let (_eloop, transport) = web3::transports::Http::new(&side_chain_addr).unwrap();
	let web3 = web3::Web3::new(transport);

	let accounts = web3.eth().accounts().wait().unwrap();

	Ok(accounts[0].to_string())
}

fn request_payment(
	addr: String,
	client_skey_encoded: String,
	side_chain_addr: String,
	smart_contract_addr: String,
	req_calculation_id: String,
	req_tx_addr: String,
) -> Result<(String), (String)> {


	Ok("placeholder".to_string())
}
