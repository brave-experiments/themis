pragma solidity >=0.4.22 <0.7.0;

contract Policy {
    
    uint constant length_policies = 2;
    uint256[length_policies] policies = [uint256(1), uint256(2)];
    
    function get_length() public pure returns (uint){
        return length_policies;
    }
    
    function get_policies() public view returns (uint256[length_policies] memory) {
        return policies;
    }   
}