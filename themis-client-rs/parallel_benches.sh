#!/bin/bash

# Runs 2 policy-sized array
for i in {1..1}
do
	SIDECHAIN_ADDR=http://54.235.4.109:22000 \
	CONTRACT_ADDR=fD3d8240Ea51CC57dBBf0b7783E6e484B7Fbb23a \
	cargo run --example e2e-benchmark &
done

