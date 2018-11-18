pragma solidity ^0.4.24;

// Owned contract is used to restrict some actions
// to the owner of the contract

contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        emit OwnershipTransferred(owner,_newOwner);
        owner = _newOwner;
    }
}

// The contact is used to track product journey through a list of 
// registered handlers in the supply chain. Handlers are identified
// by their Ethereum address, name and a chosen JSON document of
// information. Each product is identified by a unique string "uid"
// hashed in order to be used as a key to a mapping. Each product
// retains a list of actions performed by handlers on the product,
// in its journey through the supply chain.
// What this contract does:
//  - Supports registration of handlers
//  - Supports registration of products
//  - Supports registration of checkpoints of the products
//    journey
// What this contract does not do:
//  - It does not support deletion of handlers
//  - It does not support deletion of products
//  - It does not support events

contract supplyChain is Owned {
    
    // Enumeration for the existence variable of the structures
    // for rendering the code easier to read
    enum existence {NO,YES}
    
    // The handler structure retaining the name in bytes32 encoding and additional Info
    // in JSON format encoded in bytes32
    struct handler {
        
        // Name of the handler
        bytes32 name;
        
        // Info retains information in the form of a stringified JSON document.
        bytes32 addInfo;

		// Enumerated value denoting the existence
    	existence exists;
    }
    
    // A structure composed of a mapping and an array
    // usually referred to as an iterable mapping. It 
    // allows for iterating through all handlers
    // in the mapping, which traditionally is
    // impossible, by iterating through the keys.
    mapping(address => handler) handlerIndex;
    address[] handlerKeys;
    
    // The checkpoint structure retaining the handler address, a 2 uint256 array retaining the coordinates (multiplied by 10^10), 
    // the timestamp of the checkpoint and additional Info in JSON format encoded in bytes32
    struct checkpoint {
            
        // Address of the handler of the product with respect to checkpoint
        address handler;
            
        // Latitude and Longitude of the checkpoint multiplied by 10^10
        // since solidity supports only integers.
        uint256[2] coord;
            
        // Info retains additional information in the form of a stringified JSON document.
        bytes32 addInfo;
        
        // Timestamp of the checkpoint
        uint256 timestamp;
    }    
    
    // The product structure retains the unique ID of a product, mapping to the checkpoints, their number in uint256
    // and additional Info in JSON format encoded in bytes32
    struct product {
        
        // Product unique ID. Its hash is used as key to the mapping
        bytes32 uid;
                
        // Info retains all information in the form of a stringified JSON document
        bytes32 addInfo;
        
        // A mapping is used retaining all checkpoints of a product.
        // Array is avoided since it would cause error during assignment
        // from memory to storage. Assignment of structures containing arrays
        // is not yet supported.
        mapping(uint256 => checkpoint) checkpointArray;
        
        // Number of Checkpoints
        uint256 numOfCheckpoints;

    	// Enumerated value denoting the existence
    	existence exists;        
    }

    // A structure composed of a mapping and an array
    // usually referred to as an iterable mapping. It 
    // allows for iterating through all handlers
    // in the mapping, which traditionally is
    // impossible, by iterating through the keys.    
    mapping(bytes32 => product) productIndex;
    bytes32[] productKeys;
    
    // Function used for addition of handlers
    // Inputs:
    // - Handler address
    // - Handler name
    // - Handler info
    function addHandler(address handlerAddress,bytes32 handlerName,bytes32 handlerInfo) public onlyOwner {
	
        // Check existence of handler
        // Cannot add something that already exists
    	require(handlerIndex[handlerAddress].exists != existence.YES);
	        
    	handler memory currentHandler;
        currentHandler.name  = handlerName;
        currentHandler.addInfo  = handlerInfo;
    	currentHandler.exists = existence.YES;
        
        handlerIndex[handlerAddress] = currentHandler;
    
        handlerKeys.push(handlerAddress);
    }
    
    // Function used for addition of products
    // Inputs:
    // - Product unique id in the form of a string
    // - Product info
    // - Checkpoint Info (info related to the creation of the product)
    // - Latitude (x 10^10) where the product was created
    // - Longitude (x 10^10) where the product was created
    function addProduct(bytes32 uid,bytes32 productInfo,bytes32 checkpointInfo,uint256 lat,uint256 lon) public {
        
	    // Check existence of handler
	    // Cannot have fictional handlers
    	require(handlerIndex[msg.sender].exists == existence.YES);        
        
        // Temporary variable retaining the hash of the uid
        // used for the mapping
        bytes32 productAddress = keccak256(abi.encode(uid));        
        
	    // Check existence of product
	    // Cannot add something that already exists
    	require(productIndex[productAddress].exists != existence.YES);
        
        // Create structures in memory and fill them
        product memory currentProduct;
        checkpoint memory currentCheckpoint;
        currentProduct.uid  = uid;
        currentProduct.addInfo  = productInfo;
        currentProduct.numOfCheckpoints = 0;
        currentProduct.exists = existence.YES;
        
        currentCheckpoint.handler = msg.sender;
        currentCheckpoint.addInfo = checkpointInfo;
        currentCheckpoint.coord[0] = lat;
        currentCheckpoint.coord[1] = lon;
        currentCheckpoint.timestamp = now;        
    
        // Store the product
        productIndex[productAddress] = currentProduct;
        
        // Store the key to the product to the list for
        // easier tractability
        productKeys.push(productAddress);
        
        // Storage pointer to avoid long names
        product storage tmpProduct = productIndex[productAddress];
        
        // Push the checkpoint of creation
        tmpProduct.checkpointArray[tmpProduct.numOfCheckpoints] = currentCheckpoint;
        tmpProduct.numOfCheckpoints++;

    }

    // Function used for addition of a checkpoint to a product
    // Inputs:
    // - Product unique id in the form of a string
    // - Checkpoint Info (info related to the checkpoint)
    // - Latitude (x 10^10) where the product was created
    // - Longitude (x 10^10) where the product was created    
    function addCheckpoint(bytes32 uid,bytes32 checkpointInfo,uint256 lat,uint256 lon) public {
        
        // Check existence of handler
        require(handlerIndex[msg.sender].exists == existence.YES);
        
        // Temporary conversion to bytes in order to check length
        // and in turn check existence of product since uid is mandatory
        bytes32 tmpIndex = keccak256(abi.encode(uid));
        
        // Check existence of product
        require(productIndex[tmpIndex].exists == existence.YES); 
        
        // Form new checkpoint according to inputs
        checkpoint memory currentCheckpoint;
        currentCheckpoint.handler = msg.sender;
        currentCheckpoint.addInfo = checkpointInfo;
        currentCheckpoint.coord[0] = lat;
        currentCheckpoint.coord[1] = lon;
        currentCheckpoint.timestamp = now;
        
        // Create storage type pointer to avoid long names
        product storage tmpProduct = productIndex[tmpIndex];
        
        // Store checkpoint to list
        tmpProduct.checkpointArray[tmpProduct.numOfCheckpoints] = currentCheckpoint;
        tmpProduct.numOfCheckpoints++;
        
    }
    
    // Get information concerning a product with respect to its uid
    // The getter returns all checkpoint info as well as product's Additional info
    // Input:
    //  - UID of product
    // Output:
    //  - Additional Info for the Product in JSON format encoded in bytes32
    //  - List of all handlers for all Checkpoints
    //  - List of all Latitudes for all Checkpoints
    //  - List of all Longitudes for all Checkpoints
    //  - List of all timestamps for all Checkpoints
    function getProduct(bytes32 uid) public constant returns(bytes32,address[],bytes32[],uint256[],uint256[],uint256[]) {
        
        bytes32 tmpIndex = keccak256(abi.encode(uid));
        
        // Check existence of product
        require(productIndex[tmpIndex].exists == existence.YES);
        
        // Avoiding long names
        product storage tmpProduct = productIndex[tmpIndex];
        
        address[] memory handlers = new address[](tmpProduct.numOfCheckpoints);
        bytes32[] memory checkpointInfos = new bytes32[](tmpProduct.numOfCheckpoints);
        uint256[] memory lats = new uint256[](tmpProduct.numOfCheckpoints);
        uint256[] memory lons = new uint256[](tmpProduct.numOfCheckpoints);
        uint256[] memory timestamps = new uint256[](tmpProduct.numOfCheckpoints);
        
        for(uint i = 0; i < tmpProduct.numOfCheckpoints; i++) {
            handlers[i] = tmpProduct.checkpointArray[i].handler;
            checkpointInfos[i] = tmpProduct.checkpointArray[i].addInfo;
            lats[i] = tmpProduct.checkpointArray[i].coord[0];
            lons[i] = tmpProduct.checkpointArray[i].coord[1];
            timestamps[i] = tmpProduct.checkpointArray[i].timestamp;
        }
        
        return (tmpProduct.addInfo,handlers,checkpointInfos,lats,lons,timestamps);
        
    }
    
    // Get information concerning a handler based on the address
    // Input:
    //  - Address of the handler
    // Output:
    //  - Handler name
    //  - Additional Info for the handler in JSON format encoded in bytes32
    function getHandler(address addressOfHandler) public constant returns(bytes32,bytes32) {
        
        // Check existence of handler
        require(handlerIndex[addressOfHandler].exists == existence.YES);
        
        return(handlerIndex[addressOfHandler].name,handlerIndex[addressOfHandler].addInfo);
    }
    
    // Get all products
    // Output:
    //  - UIDs for all stored products
    //  - Additional info for all products in JSON format encoded in bytes32
    //  - Number of checkpoint for all products
    function getAllProducts() public constant returns(bytes32[],bytes32[],uint256[]) {
        require(productKeys.length > 0);
        bytes32[] memory uids = new bytes32[](productKeys.length);
        bytes32[] memory addInfos = new bytes32[](productKeys.length);
        uint256[] memory numsOfCheckpoints = new uint256[](productKeys.length);
        for(uint i = 0; i < productKeys.length; i++) {
            uids[i] = productIndex[productKeys[i]].uid;
            addInfos[i] = productIndex[productKeys[i]].addInfo;
            numsOfCheckpoints[i] = productIndex[productKeys[i]].numOfCheckpoints;
        }
        return(uids,addInfos,numsOfCheckpoints);
    }

    // Get all handlers
    // Output:
    //  - Addresses for all handlers
    //  - Names for all handlers in bytes32
    //  - Additional info for all products in JSON format encoded in bytes32    
    function getAllHandlers() public constant returns(address[],bytes32[],bytes32[]) {
        require(handlerKeys.length > 0);
        address[] memory addresses = new address[](handlerKeys.length);
        bytes32[] memory names = new bytes32[](handlerKeys.length);
        bytes32[] memory addInfos = new bytes32[](handlerKeys.length);
        for(uint i = 0; i < handlerKeys.length; i++) {
            addresses[i] = handlerKeys[i];
            names[i] = handlerIndex[handlerKeys[i]].name;
            addInfos[i] = handlerIndex[handlerKeys[i]].addInfo;
        }
        return(addresses,names,addInfos);
    }
}
