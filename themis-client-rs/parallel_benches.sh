#!/bin/bash

# Runs 2 policy-sized array
for i in {1..1}
do
	SIDECHAIN_ADDR=http://54.235.4.109:22000 \
	CONTRACT_ADDR=C462ea33d401AEe02623E9a310B5a8B326323Eb0 \
	cargo run --example e2e-benchmark &
done

