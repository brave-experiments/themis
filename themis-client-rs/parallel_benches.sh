#!/bin/bash

CONTRACT_ADDR_2=231248005124f9701058A440CF4889cD889633a5 #-> 2 ads
CONTRACT_ADDR_16=B441014E4BE260DFDB0CB807eD6d1baa79ba0a7E # -> 16 ads
CONTRACT_ADDR_128=6545EffDa763c2Bb1E7Fb63a09f32d1c1DEFf7fD # -> 128 ads

# 1) e2e-benchmark without on-chain verification
#	cargo run --example e2e-benchmark &

# 2) e2e-benchmark with on-chain proof verification 
#	cargo run --example e2e-benchmark-proof &

for i in {1..50}
do
	SIDECHAIN_ADDR=http://34.224.100.113:22000 \
	CONTRACT_ADDR=6545EffDa763c2Bb1E7Fb63a09f32d1c1DEFf7fD \
	cargo run --example e2e-benchmark-proof &
	#cargo run --example e2e-benchmark &
done

