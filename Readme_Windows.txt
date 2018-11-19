Windows based installation steps:

1. Download and install node.js 10.x: https://nodejs.org/en/download/ (Avoid download build tools, since they are not required) (Add npm to path during installation or afterwars) 
2. Install http-server by typing on the Command Line: npm install -g http-server
3. Navigate to root folder and edit files inserting tokens and required information as noted in Readme.md
4. On Command Line (root directory) type: http-server
5. Open a MetaMask supporting browser and navigate to: http://127.0.0.1:8080/

If compilation using python is required:
	6. Download Microsoft Build Tools 14.0 https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=15 (Takes a lot of time: 4.8 GB have to be downloaded)
	7. Download Python 3.6.7 from https://www.python.org/downloads/release/python-367/
		4.a. Add to PATH during installation or after
		4.b	. Disable 260 character maximum path length during installation or after
	8. Upgrade pip by typing on the command line: python -m pip install --upgrade pip
	9. Install web3: pip install web3
	10. Install web3py: pip install web3py
	11. Install solc by downloading from: https://github.com/ethereum/solidity/releases and adding to the PATH
	12. Install javascript solc: npm install -g solc
	13. Install py-solc: pip install py-solc
	
The python requirements (steps 9, 10 and 13) can be installed automatically by typing in the contracts folder: pip install -r deployer_requirements.txt
