#!/bin/bash

ONTRACT_ADDR_2=9D2Dd268E49A3a88c2E0DAFd10Fd6D74F634cBdB
CONTRACT_ADDR_16=9BD39D612C7dA86b6C05D3fE57C6F7deD1111375
CONTRACT_ADDR_128=4b98839Ab18FeAa5166299B4fDb0194F1BaA9612

# 1) e2e-benchmark without on-chain verification
#	cargo run --example e2e-benchmark &

# 2) e2e-benchmark with on-chain proof verification 
#	cargo run --example e2e-benchmark-proof &

for i in {1..50}
do
	SIDECHAIN_ADDR=http://34.224.100.113:22000 \
	CONTRACT_ADDR=4b98839Ab18FeAa5166299B4fDb0194F1BaA9612 \
	cargo run --example e2e-benchmark-proof &
	#cargo run --example e2e-benchmark &
done

