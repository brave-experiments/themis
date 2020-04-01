pragma solidity >=0.4.22 <0.6.0;

contract ThemisPolicyContract {
  uint constant length_policies = 2;
  uint256[length_policies] policies = [1, 2];
  
  // TODO: use structure representing point in curve across the smart contract (replace "uint256[2]" by CurvePoint{})
  struct CurvePoint {
    uint256 X;
    uint256 Y;
  }

  struct PaymentRequests {
    uint256[2] encrypted_aggregate;
    uint256[2] decrypted_aggregate;
    uint256[2] proof_correct_decryption;
    bool valid;
  }

  // public storage
  mapping (bytes32 => uint256[2][]) aggregate_storage;
  mapping (bytes32 => PaymentRequests[]) payment_requests;

  event Aggregate(uint256[2] aggr);
  event DoneProof();

  // TODO: define constructor
  constructor() public {}

  // public
  function calculate_aggregate(
    uint256[2][length_policies] memory input, 
    bytes32 client_id
  ) payable public returns (uint256[2] memory) {

    // calculates aggregate
    uint256[2] memory aggregate = _inner_product(
      input,
      policies
    );

    // stores aggregate in array keyed by client_id && return aggregate to caller
    uint256[2][] storage aggregates_client = aggregate_storage[client_id];
    aggregates_client.push(aggregate);
    
    return aggregate;
  }

  function request_payment(
    uint256[2] memory encrypted_aggregate,
    uint256[2] memory decrypted_aggregate,
    uint256[2] memory proof_correct_decryption,
    bytes32 client_id
  ) payable public returns (bool valid) {
    // TODO: implement proof verification

    bool proof_is_valid = true;

    PaymentRequests memory payment_request = PaymentRequests(
      encrypted_aggregate,
      decrypted_aggregate,
      proof_correct_decryption,
      proof_is_valid);    

    payment_requests[client_id].push(payment_request);

    return proof_is_valid;
  }

  // private
  function _inner_product(uint256[2][length_policies] memory ciphertext_vector, uint256[length_policies] memory scalar_vector) private returns (uint256[2] memory) {
      uint256[2] memory aggregate;
      uint256[2] memory resultMult;

      for (uint i = 0; i < length_policies; i++) {
        resultMult = _bn128_multiply([
          ciphertext_vector[i][0],
          ciphertext_vector[i][1], 
          scalar_vector[i]
        ]);  

        aggregate = _bn128_add([resultMult[0], resultMult[1], aggregate[0], aggregate[1]]);
        }

      emit Aggregate(aggregate);
      return aggregate;
    }

    function _bn128_add(uint256[4] memory input) private returns (uint256[2] memory result) {
        bool success;
        assembly {
            success := call(not(0), 0x06, 0, input, 128, result, 64)
        }
        require(success, "elliptic curve addition failed");
    }
  
    function _bn128_multiply(uint256[3] memory input)
    private returns (uint256[2] memory result) {
        bool success;
        assembly {
            success := call(not(0), 0x07, 0, input, 96, result, 64)
        }
        require(success, "elliptic curve multiplication failed");
    }
}
