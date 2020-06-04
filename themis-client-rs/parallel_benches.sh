#!/bin/bash

cp ../themis/build/contracts/ThemisPolicyContract.json ./build/
(cd build && make gen-gen)

# Runs 2 policy-sized array
for i in {1..1}
do
	SIDECHAIN_ADDR=http://54.165.132.197:22000/ \
	CONTRACT_ADDR=54F731DCf10DC5Af1687A88F10B84Ff1fdfbc2e6 \
	cargo run --example e2e-benchmark &
done

