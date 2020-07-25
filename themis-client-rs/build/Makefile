all:
	make gen-2-ads
	make gen-16-ads
	make gen-64-ads
	make gen-128-ads
	make gen-256-ads

gen-2-ads:
	node json_to_abi.js ThemisPolicyContract2.json > ThemisPolicyContract.abi

gen-16-ads:
	node json_to_abi.js ThemisPolicyContract16.json > ThemisPolicyContract_16ads.abi

gen-64-ads:
	node json_to_abi.js ThemisPolicyContract64.json > ThemisPolicyContract_64ads.abi

gen-128-ads:
	node json_to_abi.js ThemisPolicyContract128.json > ThemisPolicyContract_128ads.abi

gen-256-ads:
	node json_to_abi.js ThemisPolicyContract256.json > ThemisPolicyContract_256ads.abi

