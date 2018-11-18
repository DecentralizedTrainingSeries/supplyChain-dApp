import web3
import time

import sys
import os

from solc import compile_source
from web3 import Web3,HTTPProvider


######################################
# Global Parameters
# (Private Key and Public Address 
# should start with 0x..)
# (Gas price is in Gwei)
# (node_url is the url for the 
# RPC interface of a node)
# (full_contract_path is where the
# the contract is stored)
######################################
node_url = 'https://ropsten.infura.io/<token>'
privateKey = '...'
publicAdd = '...'
full_contract_path = './supplyChain.sol'
gasPrice = 2
chainId = 3


######################################
# Connection Function (RPC)
######################################
def con2ETH(full_node_url):
	t_w = Web3(HTTPProvider(full_node_url))
	return t_w


######################################
# Read and Compile solidity contract
# which is stored in *.sol file
######################################
def loadAndCompile(contract_path):
	# Open and compile file
	with open(contract_path) as f:
		file = f.read()
		compiled_sol = compile_source(file);
	return (compiled_sol)

######################################
# Deploys contract and returns
# its address and instances
######################################
def processAndDeployContract(full_node_url,contract_path,public_add,private_key,gasPrice,chainID):
	# Connect to Ethereum
	w3 = con2ETH(full_node_url)

	# Load and Compile Contract
	cntrct = loadAndCompile(full_contract_path)
	
	# Form a contract instance
	cntrct_interface = cntrct['<stdin>:supplyChain']

	cntrct_abi = cntrct_interface['abi']
	cntrct_bin = cntrct_interface['bin']
	cntrct_instance_full = w3.eth.contract(abi=cntrct_abi, bytecode=cntrct_bin)

	# Find next nonce number for the transaction
	nonce = w3.eth.getTransactionCount(public_add);

	# Estimate required gas to deploy
	gas = cntrct_instance_full.constructor().estimateGas({'from':public_add})

	# Build transaction based on all inputs
	txn = cntrct_instance_full.constructor().buildTransaction({'chainId':chainID,'gas':gas,'gasPrice': w3.toWei(gasPrice,'gwei'),'nonce':nonce})

	# Sign transaction using the Private Key
	signed_txn = w3.eth.account.signTransaction(txn,private_key = private_key)

	# Send the transaction
	w3.eth.sendRawTransaction(signed_txn.rawTransaction)

	# Convert transaction hash to hex
	txn_hash = w3.toHex(w3.sha3(signed_txn.rawTransaction))

	# Wait for the transaction to finish
	receipt = wait_for_receipt(full_node_url,txn_hash,2)

	# Get deployment address	
	deployed_contract_address = receipt['contractAddress']

	return deployed_contract_address


######################################
# Wait for transaction to pass
# Poll interval to check blockchain
# based on it.
######################################
def wait_for_receipt(full_node_url,txn_hash,poll_interval):
	# Connect to the blockchain
	w3 = con2ETH(full_node_url)
	# Wait indefinatelly for the transaction to pass
	while True:
		txn_receipt = w3.eth.getTransactionReceipt(txn_hash)
		if txn_receipt:
			return txn_receipt
		time.sleep(poll_interval)



######################################
# Cosmetics
######################################
BOLD = '\033[1m'
END = '\033[0m'

print('=========================================================')
print('=================== ' + BOLD + 'Contract Deployer' + END + ' ===================')
print('=========================================================')
print(BOLD+'The contract: '+END)
print(full_contract_path) 
print(BOLD+'Will be deployed from: '+END)
print(node_url)
print(BOLD+'With chain ID: '+END)
print(chainId)
print(BOLD+'From the address: '+END)
print(publicKey)
print(BOLD+'Warning: '+END+'Balance of the deploying address should be above a safe low in ETH')
print('=========================================================')
print(BOLD+'Contract deployment address: '+END)
print(processAndDeployContract(node_url,full_contract_path,publicAdd,privateKey,gasPrice,chainId))

