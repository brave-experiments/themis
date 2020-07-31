const ACE = artifacts.require('./ACE.sol');
const ZkAsset = artifacts.require('./ZkAsset.sol');
const ZkAssetMintable = artifacts.require('./ZkAssetMintable.sol');
const TestERC20 = artifacts.require('./TestERC20.sol');

module.exports = async (deployer, network) => {
  await deployer.deploy(TestERC20);
  const testERC20 = await TestERC20.deployed();

  let aceContract;
  if (network === 'development') {
    aceContract = await ACE.deployed();
    // initialise the ZkAsset with an ERC20 equivilant
    await deployer.deploy(
      ZkAsset,
      aceContract.address,
      testERC20.address,
      1
    );

    // initialise the private asset 
    await deployer.deploy(ZkAssetMintable,
      aceContract.address,
      '0x0000000000000000000000000000000000000000',
      1,
      0,
      [],
    );
  }
};
