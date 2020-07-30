#!/bin/bash

for server in $(cat hosts1)
do
	scp -o StrictHostKeyChecking=no -i ~/Desktop/gpestana-themis.pem ~/brave/decentralized-bat-net-experiments/themis-client-rs/src/lib.rs "$server":/home/ec2-user/themis-client-rs/src
	scp -o StrictHostKeyChecking=no -i ~/Desktop/gpestana-themis.pem ~/brave/decentralized-bat-net-experiments/themis-client-rs/examples/full-e2e-benchmark.rs "$server":/home/ec2-user/themis-client-rs/examples
done
