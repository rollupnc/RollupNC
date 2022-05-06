#!/bin/bash
set -e

circuit_name=$1
base_dir=${circuit_name}_js

circom ${circuit_name}.circom --r1cs --wasm --sym

mv ${circuit_name}.r1cs ${circuit_name}.sym  $base_dir
cd $base_dir
echo "111"
node ../../scripts/generate_${circuit_name}.js
echo "222" 

node generate_witness.js ${circuit_name}.wasm input.json witness.wtns
echo "333" 

#Prapare phase 1
#snarkjs powersoftau new bn128 16 pot12_0000.ptau -v

#snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

#Prapare phase 2
#snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

#Start a new zkey and make a contribution (enter some random text)
snarkjs zkey new ${circuit_name}.r1cs ~/Downloads/powersOfTau28_hez_final_17.ptau circuit_0000.zkey
echo "444" 

snarkjs zkey contribute circuit_0000.zkey circuit_final.zkey --name="1st Contributor Name" -v
echo "555" 

snarkjs zkey export verificationkey circuit_final.zkey verification_key.json
echo "666" 

snarkjs groth16 prove circuit_final.zkey witness.wtns proof.json public.json
echo "777" 

snarkjs groth16 verify verification_key.json public.json proof.json
echo "888" 

cd ..
snarkjs zkey export solidityverifier ${base_dir}/circuit_final.zkey ../contracts/${circuit_name}.sol
