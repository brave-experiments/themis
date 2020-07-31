[![CircleCI](https://circleci.com/gh/AztecProtocol/aztec-ganache-starter-kit.svg?style=svg)](https://circleci.com/gh/AztecProtocol/aztec-ganache-starter-kit)

# aztec-ganache-starter-kit

A repository that helps dApp developers deploy AZTEC to a local blockchain.

### Getting started

1. Clone this repository `git clone git@github.com:AztecProtocol/aztec-ganache-starter-kit.git`

2. Install the dependencies `cd aztec-ganache-starter-kit && yarn install`

3. Start up Ganache `yarn start` (This will create 5 test ethereum accounts from the credentials in `.env`)

4. Compile the contracts `yarn compile`

5. Deploy AZTEC! `yarn migrate`

6. Run the private payment demo. `yarn demo`
