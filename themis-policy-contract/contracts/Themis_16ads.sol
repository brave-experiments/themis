//pragma solidity >=0.4.22 <0.6.0;
pragma solidity >=0.4.22 <0.7.0;

contract ThemisPolicyContract16 {

  uint constant length_policies = 16;
  uint256[length_policies] policies = [
    uint256(1),
    uint256(1),
    uint256(1),
    uint256(1),
    uint256(1),
    uint256(1),
    uint256(1),
    uint256(1), // 8

    uint256(2),
    uint256(2),
    uint256(2),
    uint256(2),
    uint256(1),
    uint256(0),
    uint256(0),
    uint256(0) // 9
  ];

  struct EncryptedAggregate {
    uint256 x0;
    uint256 x1;
    uint256 y0;
    uint256 y1;
    uint256[2] public_key;
  }

  struct PaymentRequests {
    uint256[4] encrypted_aggregate;
    uint256[2] decrypted_aggregate;
    uint256[2] proof_correct_decryption;
    bool valid;
  }
    
    struct EcPoint{
        uint256 x_coord; 
        uint256 y_coord;
    }
    
    struct Ciphertext{
        EcPoint point1; 
        EcPoint point2;
    }

  // public storage
  mapping (bytes32 => PaymentRequests[]) payment_requests;
  mapping (bytes32 => EncryptedAggregate) aggregate_storage;
  mapping (bytes32 => bool) proof_verification_storage;

  event Hash(bytes32 hashed);
  event IntegerHash(uint256 int_hashed);
  event Input(uint256[4] input);
  event Aggregate(uint256[4] aggr);
  event StartSignal();
  event DoneProof();

  // TODO: define constructor
  constructor() public {}

  // TODO: only for checking
  function add_points_and_check(
    uint256[2][3] memory input
  ) payable public returns (uint256[2] memory) {
    uint256[2] memory addition = _bn128_add([input[0][0], input[0][1], input[1][0], input[1][1]]);

    require(addition[0] == input[2][0] && addition[1] == input[2][1], "equality failed");
    
    return [input[0][0], input[0][1]];

  }

  function calculate_aggregate_mock(
    uint256[4][length_policies] memory _input, 
    bytes32 _client_id
  ) payable public returns (bool) {
  
    return true;
  }

  // public
  function submit_proof_decryption(
    uint256[7] memory input, 
    bytes32 client_id
  ) payable public returns (bool) {
    // begins fetching the client's aggregate
    uint256[4] memory client_aggregate = fetch_encrypted_aggregate_array(client_id);
    uint256[2] memory client_pk = fetch_public_key(client_id);
    uint256[2] memory plaintext = [input[0], input[1]];
    uint256[2] memory announcement_g = [input[2], input[3]];
    uint256[2] memory announcement_ctx = [input[4], input[5]];
    uint256 response = input[6];

    bool proof_verification = check_proof(
      client_aggregate, 
      plaintext, 
      client_pk, 
      announcement_g, 
      announcement_ctx,
      response
    );

    proof_verification_storage[client_id] = proof_verification;

    return true;
  }

  function check_proof(
        uint256[4] memory ciphertext,
        uint256[2] memory plaintext, 
        uint256[2] memory public_key,
        uint256[2] memory announcement_g,
        uint256[2] memory announcement_ctx,
        uint256 response
    ) payable public returns (bool) {
    
        bytes32 hashed_keccak256 = keccak256(abi.encode(
            plaintext,
            ciphertext,
            announcement_g, 
            announcement_ctx, 
            [uint256(1), uint256(2)],
            public_key
            ));
            

        uint256 challenge = uint256(hashed_keccak256);
        
        bool check_1 = _proof_check_1(public_key, announcement_g, challenge, response);
        bool check_2 = _proof_check_2(ciphertext, plaintext, announcement_ctx, challenge, response);
        return check_1 && check_2;
  }
  
  function _proof_check_2(
            uint256[4] memory ciphertext, 
            uint256[2] memory plaintext, 
            uint256[2] memory announcement_ctx,
            uint256 challenge,
            uint256 response
      ) private returns (bool) {
        Ciphertext memory ctxt = Ciphertext(
                EcPoint(ciphertext[0], ciphertext[1]), EcPoint(ciphertext[2], ciphertext[3])
            );
        EcPoint memory ptxt = EcPoint(plaintext[0], plaintext[1]);
          
        uint256[2] memory lhs_mult_1_check_2 = _bn128_multiply([ctxt.point1.x_coord, ctxt.point1.y_coord, response]);
        // The following, in the original check is computed in the rhs. We do it in the lsh for simplicity
        uint256[2] memory lhs_mult_2_check_2 = _bn128_multiply([ptxt.x_coord, ptxt.y_coord, challenge]);
        uint256[2] memory lhs_check_2 = _bn128_add([lhs_mult_1_check_2[0], lhs_mult_1_check_2[1], lhs_mult_2_check_2[0], lhs_mult_2_check_2[1]]);
        
        uint256[2] memory rhs_mult_check_2 = _bn128_multiply([ctxt.point2.x_coord, ctxt.point2.y_coord, challenge]);
        uint256[2] memory rhs_check_2 = _bn128_add([announcement_ctx[0], announcement_ctx[1], rhs_mult_check_2[0], rhs_mult_check_2[1]]);
        
        bool check_2 = lhs_check_2[0] == rhs_check_2[0] && lhs_check_2[1] == rhs_check_2[1];
        return check_2;
      }
  
  function _proof_check_1(
        uint256[2] memory public_key,
        uint256[2] memory announcement_g,
        uint256 challenge,
        uint256 response
      ) private returns (bool) {
        EcPoint memory pk = EcPoint(public_key[0], public_key[1]);
        EcPoint memory generator = EcPoint(uint256(1), uint256(2));
        
        uint256[2] memory lhs_check_1 = _bn128_multiply([generator.x_coord, generator.y_coord, response]);
    
        uint256[2] memory pk_times_challenge = _bn128_multiply([pk.x_coord, pk.y_coord, challenge]);
        uint256[2] memory rhs_check_1 = _bn128_add([announcement_g[0], announcement_g[1], pk_times_challenge[0], pk_times_challenge[1]]);    
  
        bool check_1 = lhs_check_1[0] == rhs_check_1[0] && lhs_check_1[1] == rhs_check_1[1];
        return check_1;
  }

  function calculate_aggregate(
    uint256[4][length_policies] memory input, 
    uint256[2] memory public_key,
    bytes32 client_id
  //) payable public returns (uint256[4] memory) {
    ) payable public returns (bool) {    
    emit Input(input[0]);
    emit Input(input[1]);
    
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
      y1: aggregate[3], 
      public_key: public_key
    });

    aggregate_storage[client_id] = enc_aggr;

    return true;
  }

  // supposed to replace `fetch_encrypted_aggregate` at some point. I like more uint256[4] than (.,.,.,.)
  function fetch_encrypted_aggregate_array(bytes32 client_id) public view returns (uint256[4] memory) {
    return [aggregate_storage[client_id].x0, aggregate_storage[client_id].x1, aggregate_storage[client_id].y0, aggregate_storage[client_id].y1];
  }
  function fetch_encrypted_aggregate(bytes32 client_id) public view returns (uint256, uint256, uint256, uint256) {
      return  (aggregate_storage[client_id].x0, aggregate_storage[client_id].x1, aggregate_storage[client_id].y0, aggregate_storage[client_id].y1);
  }

  function fetch_public_key(bytes32 client_id) public view returns (uint256[2] memory ) {
    return aggregate_storage[client_id].public_key;
  }

  function fetch_proof_verification(bytes32 client_id) public view returns (bool) {
    return proof_verification_storage[client_id];
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
  function _inner_product(
    uint256[4][length_policies] memory ciphertext_vector, 
    uint256[length_policies] memory scalar_vector
  ) private returns (uint256[4] memory) {

      uint256[2] memory aggregate_1 = [uint256(0), uint256(0)];
      uint256[2] memory aggregate_2 = [uint256(0), uint256(0)];
      uint256[2] memory resultMult_1 = [uint256(1), uint256(1)];
      uint256[2] memory resultMult_2 =  [uint256(1), uint256(1)];

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
