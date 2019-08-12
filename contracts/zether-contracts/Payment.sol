pragma solidity >=0.4.21 <0.6.0;

contract Payment {
  address public owner;
  address public policyContract;
  uint public currentAggrId;
  mapping (uint => string) payments;

  constructor(address pc) public {
    owner = msg.sender;
    currentAggrId = 0;
    policyContract = pc;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function validateAndPay(address _payAddr, string memory aggr, string memory _aggrProof) public returns (string memory) {

    payments[currentAggrId] = aggr;
    incrementAddr();
    return aggr;
  }

  function incrementAddr() private {
    currentAggrId += 1;
  }

  // marks policy as funded
  function fund() private {}
}