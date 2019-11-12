## Decentralized BAT network experiments

This repo maintains code part of the research efforts, PoCs, and testing for
exploring privacy preserving PoA chains.

### Performance of anonymous and confidential payments on PoA chains

We have tested and measured both [AZTEC](https://github.com/AztecProtocol/AZTEC)
and [Anonymous-Zether](https://github.com/jpmorganchase/anonymous-zether) under
several settings. You can check the plots of the results [here](./plots). 

The initial measurements were performed against a 7-node Quorum PoA chain
running locally. You may check in [Quorum's examples
repository](https://github.com/jpmorganchase/quorum-examples) how to set it up
how to run the sidechain locally.

**A. AZTEC performance measurements**: 

1) Clone the [AZTEC ganache starter kit](https://github.com/AztecProtocol/aztec-ganache-starter-kit)
2) Change truffle [configurations](./aztec/)
3) Edit the [demo code](./aztec/demo.js) for running and measuring performance
with different setups.
4) Replace `demo.js` and truffle configuration files in the AZTEC ganache starter kit;
5) Run a Pantheon or Quorum PoA chain and deploy the smart contracts using truffle
6) Run the measurements

**B. Zether performance measurements**

1) Clone the [Anonymous Zether
repo](https://github.com/jpmorganchase/anonymous-zether). You may also use the setup in [this repo](./quorum-network)
2) Make sure a Quorum (compatible only with Quorum for now) sidechain is running locally;
4) Clone the [Anonymous Zether example repo](https://github.com/jpmorganchase/anonymous-zether)
3) Use the examples in [client.js](./anon-zether/client.js) and
[index.js](./anon-zether/index.js) to modify `packages/anonymous.js/src/client.js` and `packages/example/index.js` and setup the measurements.


**C. Measurement plotting and results**

You can check the results and python scripts to generate the plots [here](./plots).

### Background

[Privacy Preserving and Decentralized Brave Rewards - slides (deprecated)](https://docs.google.com/presentation/d/1Z-SSLBkcZfuTQOTjwB1lU5HoSkYUSBlxd0F__nHQgvc/edit#slide=id.p1)

--- 

Brave Research Team
