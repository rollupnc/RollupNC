CIRCOM=circom
SNARKJS=./node_modules/.bin/snarkjs
NODE=node
CRS=~/Downloads/powersOfTau28_hez_final_24.ptau

all: \
	build/Update_verifier.sol \
	build/Withdraw_verifier.sol 

build/withdraw_signature_verifier.r1cs build/withdraw_signature_verifier.wasm:
	( cd circuits && ${CIRCOM} withdraw_signature_verifier.circom --r1cs -o ../build/)

build/withdraw_proving_key.json build/withdraw_verification_key.json: build/withdraw_signature_verifier.json
	${SNARKJS} setup --protocol groth --c build/withdraw_signature_verifier.json --pk build/withdraw_proving_key.json --vk build/withdraw_verification_key.json

build/Withdraw_verifier.sol : build/withdraw_verification_key.json
	${SNARKJS} generateverifier --vk build/withdraw_verification_key.json --v build/Withdraw_verifier.sol

build/update_circuit.r1cs:
	( cd circuits && ${CIRCOM} update_state_verifier.circom -o ../build/update_circuit.json )

build/update_proving_key.json build/update_verification_key.json: build/update_circuit.json
	${SNARKJS} setup --protocol groth  --c build/update_circuit.json --pk build/update_proving_key.json --vk build/update_verification_key.json

build/Update_verifier.sol : build/update_verification_key.json
	${SNARKJS} generateverifier --vk build/update_verification_key.json --v build/Update_verifier.sol

test_files: build/test_1_update_proof.json build/test_1_withdraw_proof.json

build/test_1_update_proof.json: build/test_1_update_witness.json
	${SNARKJS} proof --w build/test_1_update_witness.json --pk build/update_proving_key.json --p build/test_1_update_proof.json --pub build/test_1_update_public.json
	${SNARKJS} verify --vk build/update_verification_key.json --p build/test_1_update_proof.json --pub build/test_1_update_public.json

build/test_1_update_witness.json: build/test_1_update_input.json
	${SNARKJS} calculatewitness --c build/update_circuit.json --i build/test_1_update_input.json --w build/test_1_update_witness.json

build/test_1_update_input.json:
	${NODE} utils/1_generate_multiple_sample.js

build/test_1_withdraw_proof.json: build/test_1_withdraw_witness.json
	${SNARKJS} proof --w build/test_1_withdraw_witness.json --pk build/withdraw_proving_key.json --p build/test_1_withdraw_proof.json --pub build/test_1_withdraw_public.json
	${SNARKJS} verify --vk build/withdraw_verification_key.json --p build/test_1_withdraw_proof.json --pub build/test_1_withdraw_public.json

build/test_1_withdraw_witness.json: build/test_1_withdraw_input.json
	${SNARKJS} calculatewitness --c build/withdraw_signature_verifier.json --i build/test_1_withdraw_input.json --w build/test_1_withdraw_witness.json

build/test_1_withdraw_input.json:
	${NODE} utils/1_generate_withdraw_signature.js
