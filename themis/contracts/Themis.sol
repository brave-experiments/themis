//pragma solidity >=0.4.22 <0.6.0;
pragma solidity >=0.4.22 <0.7.0;


contract ThemisPolicyContract {
  uint constant length_policies = 2;
  uint256[length_policies] policies = [1, 2];

  struct EncryptedAggregate {
    uint256 x0;
    uint256 x1;
    uint256 y0;
    uint256 y1;
  }

  struct PaymentRequests {
    uint256[4] encrypted_aggregate;
    uint256[2] decrypted_aggregate;
    uint256[2] proof_correct_decryption;
    bool valid;
  }

  // public storage
  mapping (bytes32 => PaymentRequests[]) payment_requests;
  mapping (bytes32 => EncryptedAggregate) aggregate_storage;

  event Aggregate(uint256[4] aggr);
  event DoneProof();

  // TODO: define constructor
  constructor() public {}

  // public 
  function add_points_and_check(
    uint256[2][3] memory input
  ) payable public returns (uint256[2] memory) {
    uint256[2] memory addition = _bn128_add([input[0][0], input[0][1], input[1][0], input[1][1]]);

    require(addition[0] == input[2][0] && addition[1] == input[2][1], "equality failed");
    
    return [input[0][0], input[0][1]];

  }
  // public
  function calculate_aggregate(
    uint256[4][length_policies] memory input, 
    bytes32 client_id
  ) payable public returns (uint256[4] memory) {

    // calculates aggregate
    uint256[4] memory aggregate = _inner_product(
      input,
      policies
    );

    // stores aggregate in array keyed by client_id && return aggregate to caller
    EncryptedAggregate memory enc_aggr = EncryptedAggregate({ 
      x0: aggregate[0], 
      x1: aggregate[1], 
      y0: aggregate[2], 
      y1: aggregate[3]
    });
    aggregate_storage[client_id] = enc_aggr;

    return aggregate;
  }

  function fetch_encrypted_aggregate(bytes32 client_id) public view returns (uint256, uint256, uint256, uint256) {
      return  (aggregate_storage[client_id].x0, aggregate_storage[client_id].x1, aggregate_storage[client_id].y0, aggregate_storage[client_id].y1);
  }

  function request_payment(
    uint256[4] memory encrypted_aggregate,
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
  function _inner_product(uint256[4][length_policies] memory ciphertext_vector, uint256[length_policies] memory scalar_vector) private returns (uint256[4] memory) {
      uint256[2] memory aggregate_1;
      uint256[2] memory aggregate_2;
      uint256[2] memory resultMult_1;
      uint256[2] memory resultMult_2;

      for (uint i = 0; i < length_policies; i++) {
        resultMult_1 = _bn128_multiply([
          ciphertext_vector[i][0],
          ciphertext_vector[i][1], 
          scalar_vector[i]
        ]);  

        resultMult_2 = _bn128_multiply([
          ciphertext_vector[i][2], 
          ciphertext_vector[i][3],
          scalar_vector[i]
        ]);

        aggregate_1 = _bn128_add([resultMult_1[0], resultMult_1[1], aggregate_1[0], aggregate_1[1]]);
        aggregate_2 = _bn128_add([resultMult_2[0], resultMult_2[1], aggregate_2[0], aggregate_2[1]]);
        }

      uint256[4] memory aggregate = [aggregate_1[0], aggregate_1[1], aggregate_2[0], aggregate_2[1]];
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
