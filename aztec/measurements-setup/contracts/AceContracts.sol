
pragma solidity >= 0.5.0 <0.7.0;
// import the aztec contracts so truffle compiles them
import "@aztec/protocol/contracts/interfaces/IAZTEC.sol";
import "@aztec/protocol/contracts/ACE/ACE.sol";
import "@aztec/protocol/contracts/ACE/validators/joinSplitFluid/JoinSplitFluid.sol";
import "@aztec/protocol/contracts/ACE/validators/swap/Swap.sol";
import "@aztec/protocol/contracts/ACE/validators/joinSplit/JoinSplit.sol";
import "@aztec/protocol/contracts/ACE/validators/dividend/Dividend.sol";
import "@aztec/protocol/contracts/ACE/validators/privateRange/PrivateRange.sol";
import "@aztec/protocol/contracts/ACE/noteRegistry/epochs/201907/base/FactoryBase201907.sol";
import "@aztec/protocol/contracts/ACE/noteRegistry/epochs/201907/adjustable/FactoryAdjustable201907.sol";
import "@aztec/protocol/contracts/ERC1724/ZkAsset.sol";

contract DummyContract {

}
