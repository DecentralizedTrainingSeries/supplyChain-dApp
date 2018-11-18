
**Decentralized Training Series 2018**

**supplyChain: A simple supply chain blockchain dApp**


---------------
Description
---------------

The dApp is composed of two parts: (i) contracts, and (ii) web interface. The supplyChain contract utilizes the Owned contract for handling access. The owner of the contract can register Handlers and in turn Handlers register Products and log Checkpoints where products passthrough. 
The interface is based on a multi-tab approach allowing for interaction with the deployed smart contracts easily by handling required conversions and beautifying outputs. Connection to the Ethereum blockchain is established through injection from Metamask (after logging in). Deployment can be performed by any deployment tool e.g., Remix or Truffle.

---------------
Requirements and Installation
---------------

- NPM package manager: NPM package manager is required to obtain basic software packages. Installation info can be found at:
	https://github.com/creationix/nvm/blob/master/README.md#installation

- Metamask with available Ether: Ether is required to deploy the contract to the Ethereum blockchain and to interact with the contract.

- Contract deployment: Copy the code from supplyChain.sol file into:
	https://remix.ethereum.org
and deploy using a Metamask account with available Ether. The address of the contract should be copied and pasted in the index.js file at the line:
	
	var contractInstance = supplyChain.at('contract address');

- Google Maps Javascript API key: The Javascript key is obtained by following the instructions given at:

	https://developers.google.com/maps/documentation/javascript/get-api-key

The key (with limited number of requests) can be obtained. The key should be copied and pasted in the index.html file at:

	<script async defer src="https://maps.googleapis.com/maps/api/js?key=<Google Maps Javascript Key>"
	
The Google Maps key is required to visualize the the path that a product has followed.

- Solc compiler: The solc compiler is required to compile the contracts and extract the abi (contract/abi/<contract_abi>) in case of performed changes. Installation of the solc is performed as: 
	
	```
	npm install -g solc
	```	
Compilation of contracts is performed as:
	```
	soljs --abi <contract_name>.sol
	soljs --bin <contract_name>.sol
	```
	
The results of compilation should be placed into corresponding folders in contracts folder. The default (preconmpiled) files are provided.

- Simple Http server: The http server is required to serve the interface for testing. Installation of the simple http server is performed through npm:

	```
	npm install -g http-server
	```
	
The server should be initialized in the root directory `(.)`:

	
	http-server ./
	
---------------
Custom deployment script
---------------

In folder contracts there is a custom deployment script for deploying the Smart Contract supplyChain.sol. The Smart Contract requires an Infura token, ontained from https://infura.io/, a private and a public address from an Ethereum account with enough Eth for the deployment. Other parameters include the Chain ID, which depends on the network chosen for deployment.

Installation procedure of the required libraries is as follows:

```
pip3.6 install web3
pip3.6 install py-solc

python3.6 -m solc.install v0.4.24
```

And to run the script

```
python3.6 deploy.py
```

This script deploys the supplyChain contract and waits until this procedure is confirmed, it then returns the contract address.

---------------
Files and Folders
---------------

Files and folders structure is as follows:


```bash
.
|-- contracts
|   |-- abi
|   |   |-- supplyChain_sol_Owned.abi
|   |   `-- supplyChain_sol_supplyChain.abi
|   |-- bin
|   |   |-- supplyChain_sol_Owned.bin
|   |   `-- supplyChain_sol_supplyChain.bin
|   |-- deployer.py
|   `-- supplyChain.sol
|-- css
|   `-- index.css
|-- favicon.ico
|-- img
|   `-- dts-logo.png
|-- index.html
|-- js
|   `-- index.js
`-- Readme.md
```
