pragma solidity >=0.4.22 <0.6.0;

contract ElGamal {

    uint constant length_policies = 4;
    
    event Aggregate(uint256[2] aggr);
    event DoneProof();

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

    function decryption_proof() public {
      uint256[2] memory one;
      uint256[2] memory two;
      uint256[2] memory three;
      uint256[2] memory four;
      uint256[2] memory five;
      bytes32 hash;

      uint256 X = uint256(1368015179489954701390400359078579693043519447331113978918064868415326638035);
      uint256 Y = uint256(9918110051302171585080402603319702774565515993150576347155970296011118125764);
      uint256 scalar = 2;

      one = bn128_multiply([X, Y, scalar]);
      two = bn128_multiply([X, Y, scalar]);
      three = bn128_multiply([X, Y, scalar]);
      four =  bn128_add([X, Y, X, Y]);
      five =  bn128_add([X, Y, X, Y]);

      hash = keccak256("9918110051302171585080402603319702774565515993150576347155970296011118125764, 9918110051302171585080402603319702774565515993150576347155970296011118125764, 9918110051302171585080402603319702774565515993150576347155970296011118125764, 9918110051302171585080402603319702774565515993150576347155970296011118125764");
      emit DoneProof();
      return;
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
