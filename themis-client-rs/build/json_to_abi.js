const fs = require('fs');

const contract = JSON.parse(fs.readFileSync('./ThemisPolicyContract.json', 'utf8'));

console.log(JSON.stringify(contract.abi));
