pragma solidity >=0.4.21 <0.6.0;

contract Escrow {
  address public owner;
	uint amount;

	constructor() public {
    owner = msg.sender;
    amount = 0;
  }

	function fund() public payable{
		amount += msg.value;
	}
}
