pragma solidity >=0.4.21 <0.6.0;

contract Payment {
  address public owner;
  address public ads_escrow_account;
  uint[] public encrypted_aggregates;
  uint[] public policy_arr;


  constructor(uint[] memory parr, address acc) public {
    owner = msg.sender;
    policy_arr = parr;
    ads_escrow_account = acc;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  // public function that computes aggregate over encrypted policy and click
  // array and saves the encrypted aggregate in the storage 
  function compute_aggregate(uint[] memory click_arr) public returns (uint) {
    uint aggr;
    
    // calculate encrypted aggregate 
    aggr = aggregate_sum(click_arr);

    if (aggr != 0) {
      encrypted_aggregates.push(aggr);
    }

    return aggr;
  }

  // returns current state of encrypted aggregates
  function get_aggregates() public view returns (uint[] memory) {
    return encrypted_aggregates;
  }

  // given a valid aggregate decryption proof and a decrypted aggregate sum,
  // pays sum to zether account in using Zether escrow account 
  function transfer_funds(uint dec_aggr, uint proof, address to_addr) public pure {
    bool valid_request;
    
    valid_request = is_valid_decryption(dec_aggr, proof);
    if (!valid_request) {
      // not a valid decryption
      return;
    } 

    // transfer funds to to_addr from escrow account `ads_escrow_account`
  }

  // checks aggregate value against proof decryption and returns bool
  // according to its validity
  // TODO: returning true if proof == dec_agggr * 10
  function is_valid_decryption(uint dec_aggr, uint proof) private pure returns (bool) {
    if (proof == dec_aggr * 10) {
      return true;
    }
    return false;
  }

  // Performs homomorphic sum of the clickArr over policyArr
  // currently, it adds performs aggregate of click_arr without encryption, 
  // i.e. policy_arr[i] * click_arr, for all i E policy_arr.length 
  function aggregate_sum(uint[] memory click_arr) private view returns (uint) {
    uint aggr;


    if (click_arr.length != policy_arr.length) {
      // error
      return 0;
    }

    for (uint i = 0; i < policy_arr.length; i++) {
      aggr = aggr + (policy_arr[i] * click_arr[i]);
    }

    return aggr;
  }
}