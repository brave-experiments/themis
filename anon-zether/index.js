const Web3 = require("web3");
const Client = require("../anonymous.js/src/client.js");
const ZSC = require("../contract-artifacts/artifacts/ZSC.json");
const Deployer = require('./deployer.js');
const Provider = require('./provider.js');

(async () => {
    var provider = new Provider("ws://localhost:23000");
    const web3 = new Web3(await provider.getProvider());

    web3.transactionConfirmationBlocks = 1;
    var deployer = new Deployer();
    const zether = (await deployer.deployZetherVerifier()).contractAddress;
    const burn = (await deployer.deployBurnVerifier()).contractAddress;
    const cash = (await deployer.deployCashToken()).contractAddress;
    await deployer.mintCashToken(cash);
    const zsc = (await deployer.deployZSC(cash, zether, burn, 6)).contractAddress; // epoch length in seconds.
    await deployer.approveCashToken(cash, zsc)
    const deployed = new web3.eth.Contract(ZSC.abi, zsc);
    
    const accounts = await web3.eth.getAccounts();
    console.log(accounts)
    const client = new Client(deployed, accounts[0], web3);
    await client.initialize();
    await client.deposit(10000);
    await client.withdraw(1);
    client.friends.add("Alice", ['0x0eaadaaa84784811271240ec2f03b464015082426aa13a46a99a56c964a5c7cc', '0x173ce032ad098e9fcbf813696da92328257e58827f3600b259c42e52ff809433']);

    let times = [];
    let n = 10;
    for (var i = 0; i < n; i++) {
        let t_b = new Date();
        
        await client.transfer('Alice', 1);
        
        let t_a = new Date()
        
        let ti = t_a -t_b + 75;
        console.log(ti)
        times.push(ti);
    }

    console.log(times)

})().catch(console.error);