#!/bin/bash

ONTRACT_ADDR_2=6e0feCa2EBe9AF5178441de09511F08a08fd0A30
CONTRACT_ADDR_16=867F6549FB265651673E5f404502c02CbAEF82c5
CONTRACT_ADDR_64=CA95E80e3E44bc84C0C17A0aa500aa1d3925C108
CONTRACT_ADDR_128=Bb119BaB77D8e4D69564B42cbfae0D454a3f21F3
CONTRACT_ADDR_256=cf4Dc563E423277feB59361E8d6037849e61e1E3

# 1) e2e-benchmark without on-chain verification
#	cargo run --example e2e-benchmark &

# 2) e2e-benchmark with on-chain proof verification 
#	cargo run --example e2e-benchmark-proof &

for i in {1..10}
do
	SIDECHAIN_ADDR=http://52.54.139.150:22000 \
	CONTRACT_ADDR=cf4Dc563E423277feB59361E8d6037849e61e1E3 \
	cargo run --example full-e2e-benchmark &
	#cargo run --example reward-request-benchmark &
done

