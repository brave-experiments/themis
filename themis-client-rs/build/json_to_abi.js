const fs = require('fs');

var jsonPath = process.argv[2];
const contract = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

console.log(JSON.stringify(contract.abi));
