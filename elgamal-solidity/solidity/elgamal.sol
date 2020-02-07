pragma solidity >=0.4.22 <0.6.0;

contract ElGamal {

    uint constant length_policies = 4;
    
    event Aggregate(uint256[2] aggr);

    function inner_product(uint256[2][length_policies] memory ciphertext_vector, uint256[length_policies] memory scalar_vector) payable public returns (uint256[2] memory)
    {

        uint256[2] memory aggregate;
        uint256[2] memory resultMult;

        for (uint i = 0; i < length_policies; i++) {
          resultMult = bn128_multiply([
            ciphertext_vector[i][0],
            ciphertext_vector[i][1], 
            scalar_vector[i]
          ]);  

          aggregate = bn128_add([resultMult[0], resultMult[1], aggregate[0], aggregate[1]]);
        }

        emit Aggregate(aggregate);
        return aggregate;
    }
  
    function bn128_add(uint256[4] memory input) private returns (uint256[2] memory result) {
        bool success;
        assembly {
            success := call(not(0), 0x06, 0, input, 128, result, 64)
        }
        require(success, "elliptic curve addition failed");
    }
  
    function bn128_multiply(uint256[3] memory input)
    private returns (uint256[2] memory result) {
        bool success;
        assembly {
            success := call(not(0), 0x07, 0, input, 96, result, 64)
        }
        require(success, "elliptic curve multiplication failed");
    }
}