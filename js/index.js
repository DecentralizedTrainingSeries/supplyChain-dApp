// Connect to the Ethereum blockchain using the provider of MetaMask
var web3 = new Web3(web3.currentProvider);

// Synchronous read of the contract's ABI
var response = jQuery.get({url:'contracts/abi/supplyChain_sol_supplyChain.abi', 
			async:false, 
			success:function(data) {}
			});

// Parsing Application Binary Interface (ABI) of the supplyChain smart contract in JSON format.
// Bytes32 inputs require prior conversion of data with web3.fromAscii, when 
// calling methods. The inverse is required when getting data from the 
// Ethereum blockchain (web3.toAscii).
var abi = JSON.parse(response.responseText);

// Create the supplyChain smart contract instance
var supplyChain = web3.eth.contract(abi);

// The address at which the smart contract is deployed
var contractInstance = supplyChain.at('0xfb4a4fcc38f91596d7ec25f8834dd79077bcef59');

// Function used to register a Handler
function registerHandler() {
	// Check connectivity
	if(web3.isConnected == false)
	{
		alert("Register Handler: No connection to the Ethereum")
	}
	else
	{

		let ethadd = $("#ethadd").val();
		let hname = $("#hname").val();

		// Convert to JSON
		let hadd = '{"address":"'+$("#haddr").val()+'"}';
		// Contract method invocation in order to store Handler
		contractInstance.addHandler(ethadd,web3.fromAscii(hname),web3.fromAscii(hadd),{from: 			web3.eth.accounts[0]}, function(err1,res1) {
				document.getElementById("addhandstat").innerHTML = "Sent TX#: " + res1;	
			});
	}
}

// Function used to register a Product
function registerProduct() {
	// Check connectivity
	if(web3.isConnected == false)
	{
		alert("Register Product: No connection to the Ethereum")
	}
	else
	{

		let uid = $("#uid").val();

		// Convert to JSON document
		let prodInfo = '{"name":"'+$("#name").val()+'"}';
		let chkInfo = '{"action":"'+$("#action").val()+'"}';

		// Cast Latitude and Longitude to integers by multiplication with 10^10
		let lat = parseFloat($("#lat").val())*Math.pow(10,10);
		let lon = parseFloat($("#lon").val())*Math.pow(10,10);

		// Contract method invocation in order to store Product
		contractInstance.addProduct(web3.fromAscii(uid),web3.fromAscii(prodInfo),web3.fromAscii(chkInfo),lat,lon,{from: 			web3.eth.accounts[0]}, function(err1,res1) {
				document.getElementById("addprodstat").innerHTML = "Sent TX#: " + res1;	
			});
	}
}

// Function to add Checkpoint to Checkpoint
function addCheckpoint() {
	// Check connectivity
	if(web3.isConnected == false)
	{
		alert("Add Checkpoint: No connection to the Ethereum")
	}
	else
	{
		let uid = $("#cuid").val();

		// Convert to JSON document
		let action = '{"action":"'+$("#caction").val()+'"}';
		
		// Cast Latitude and Longitude to integers by multiplication with 10^10
		let lat = parseFloat($("#clat").val())*Math.pow(10,10);
		let lon = parseFloat($("#clon").val())*Math.pow(10,10);

		// Contract method invocation in order to store Checkpoint
		contractInstance.addCheckpoint(web3.fromAscii(uid),web3.fromAscii(action),lat,lon,{from: 			web3.eth.accounts[0]}, function(err1,res1) {
				document.getElementById("addchkpnt").innerHTML = "Sent TX#: " + res1;	
			});
	}
}

// Function used to cleaned trailing zeros of Bytes32 type data returned from the Ethereum Blockchain
function cleanPadding(bstr) {
	let len = bstr.length;
	let i = len;
	// Count amount of zeroes
	while (i >= 1) {
		if(bstr[i-1] != '0') {
			break;
		}
		i--;
	}
	return(bstr.substring(0,i));
}

// Function used to track a Product
function trackProduct() {
	// Check connectivity
	if(web3.isConnected == false)
	{
		alert("Track Product: No connection to the Ethereum")
	}
	else
	{
		let uid = $("#tuid").val();

		// Call contract method
		contractInstance.getProduct(web3.fromAscii(uid), function(err1,res1) {

				// Read number of Checkpoints
				let numOfCheckpoints = res1[1].length;

				// Fetch JSON after decoding from Bytes32, before removing padding
				let tmpJSON = JSON.parse(web3.toAscii(cleanPadding(res1[0])));

				// Create HTML table to enlist checkpoints
				str = '<h3>Product Name: '+tmpJSON["name"]+'</h3>';
				str = str + '<div class="table-responsive"><table class="table table-bordered"><thead><tr><th>#</th><th>Handler Address</th><th>Action</th><th>Latitude</th><th>Longitude</th><th>Timestamp</th></tr></thead><tbody>';
				let lats = new Array();
				let lons = new Array();
				let actions = new Array();
				let clat = 0.0;
				let clon = 0.0;

				// Store all info to the table
				for(let i = 0; i < numOfCheckpoints; i++) {

					// Parse JSON after removing padding and decoding from Bytes32
					tmpJSON = JSON.parse(web3.toAscii(cleanPadding(res1[2][i])));
					let date = new Date(Number(res1[5][i])*1000);

					// Convert latitudes and longitudes to float
					lats.push(parseFloat(res1[3][i])/Math.pow(10,10));
					lons.push(parseFloat(res1[4][i])/Math.pow(10,10));
					actions.push(tmpJSON["action"]);

					// Compute sum of latitudes and longitudes in order to compute the 
					// center of mass of the Checkpoints' positions in order to 
					// center the map properly
					clat += lats[i];
					clon += lons[i];
					str = str + '<tr><td>'+String(i+1) + '</td>' +'<td>'+res1[1][i] + '</td>' + '<td>'+actions[i]+'</td>' + '<td>'+String(lats[i])+'</td>' + '<td>'+String(lons[i])+'</td>' + '<td>'+date.toISOString()+'</td></tr>';
				}

				// Finalize HTML table
				str = str + '</tbody></table></div>';
				str = str + '<center><h3>Map</h3></center>'
				document.getElementById("chkpnts").innerHTML = str;

				// Compute center of mass
				clat /= numOfCheckpoints;
				clon /= numOfCheckpoints;

				// Create map object of type ROADMAP centered at the center of mass
				var map = new google.maps.Map(document.getElementById('map'), {
					zoom: 5,
					center: new google.maps.LatLng(clat,clon),
					mapTypeId: google.maps.MapTypeId.ROADMAP
				});

				// Create InfoWindow object to store details of the pins on the map
				var infowindow = new google.maps.InfoWindow();
		
				var mark, i;

				// Create markers on the map
				for (let i = 0; i < numOfCheckpoints; i++) {  
					marker = new google.maps.Marker({
					position: new google.maps.LatLng(lats[i],lons[i]),
					map: map
				});
				
				// Write info to InfoWindow for each marker on the map
				google.maps.event.addListener(marker, 'click', (function(marker, i) {
					return function() {
						infowindow.setContent(String(i+1)+'. '+actions[i]);
						infowindow.open(map, marker);
					}
					})(marker, i));
				}

			});
	}
}

// Function to get Handler info
function getHandler() {
	// Check connectivity
	if(web3.isConnected == false)
	{
		alert("Get Handler: No connection to the Ethereum")
	}
	else
	{
		let handadd = $("#handadd").val();

		// Get Handler information by calling contract method
		contractInstance.getHandler(handadd, function(err1,res1) {

				// Create JSON document by removing padding and deconding from Bytes32
				let tmpJSON = JSON.parse(web3.toAscii(cleanPadding(res1[1])));
				str = '<div class="table-responsive"><table class="table table-bordered"><thead><tr><th>Handler Address</th><th>Name</th><th>Address</th></tr></thead><tbody>';
				
				str = str + '<tr><td>'+ handadd + '</td>' +'<td>'+web3.toAscii(cleanPadding(res1[0])) + '</td>' + '<td>'+tmpJSON["address"]+'</td></tr>';

				str = str + '</tbody></table></div>';
				document.getElementById("gethandinfo").innerHTML = str;

			});
	}
}

// Function to fetch all Handlers
function getAllHandlers() {
	// Check connectivity
	if(web3.isConnected == false)
	{
		alert("Get All Handlers: No connection to the Ethereum")
	}
	else
	{
		// Get all Handlers (without Checkpoints) 
		contractInstance.getAllHandlers(function(err1,res1) {
				let numOfHandlers = res1[0].length;
				str = '<div class="table-responsive"><table class="table table-bordered"><thead><tr><th>#</th><th>Handler Address</th><th>Name</th><th>Address</th></tr></thead><tbody>';

				console.log(res1);
				// Loop over all handlers, clean padding and decode from Bytes32
				for(let i = 0; i < numOfHandlers; i++) {
					let tmpJSON = JSON.parse(web3.toAscii(cleanPadding(res1[2][i])));
				
					str = str + '<tr><td>'+ String(i+1) + '</td>' + '<td>' + res1[0][i] + '</td>' +'<td>'+web3.toAscii(cleanPadding(res1[1][i])) + '</td>' + '<td>'+tmpJSON["address"]+'</td></tr>';

				}
				str = str + '</tbody></table></div>';
				document.getElementById("getallhandinfo").innerHTML = str;

			});
	}
}

// Function to fetch all Products
function getAllProducts() {
	// Check connectivity
	if(web3.isConnected == false)
	{
		alert("Get All Products: No connection to the Ethereum")
	}
	else
	{
		// Get all products by calling contract method
		contractInstance.getAllProducts(function(err1,res1) {
				let numOfProducts = res1[0].length;
				str = '<div class="table-responsive"><table class="table table-bordered"><thead><tr><th>#</th><th>Unique ID</th><th>Name</th><th>Number of Checkpoints</th></tr></thead><tbody>';

				// Loop over all products, clean padding and decode from Bytes32
				for(let i = 0; i < numOfProducts; i++) {
					let tmpJSON = JSON.parse(web3.toAscii(cleanPadding(res1[1][i])));
					str = str + '<tr><td>'+ String(i+1) + '</td>' + '<td>' + web3.toAscii(cleanPadding(res1[0][i])) + '</td>' +'<td>' + tmpJSON["name"] + '</td>' + '<td>'+ res1[2][i] +'</td></tr>';

				}
				str = str + '</tbody></table></div>';
				document.getElementById("getallprodinfo").innerHTML = str;

			});
	}
}

// W3schools function for tab handling
function openTab(evt, tabname) {
    // Declare all variables
    var i, tabcontent, tablinks;

    // Get all elements with class="tabcontent" and hide them
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }

    // Get all elements with class="tablinks" and remove the class "active"
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
    }

    // Show the current tab, and add an "active" class to the button that opened the tab
    document.getElementById(tabname).style.display = "block";
    evt.currentTarget.className += " active";
}
