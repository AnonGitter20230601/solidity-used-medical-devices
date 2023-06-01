
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.18;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: Trading_Guarded.sol



// File: @chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol



pragma solidity ^0.8.18;

interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/AutomationBase.sol


pragma solidity ^0.8.18;

contract AutomationBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/AutomationCompatible.sol


pragma solidity ^0.8.18;



abstract contract AutomationCompatible is AutomationBase, AutomationCompatibleInterface {}

// File: Registration.sol



pragma solidity ^0.8.18;


contract Registration {

        address immutable FDA;

        mapping(address => bool) public Manafacture;
        mapping(address => bool) public Refurbishment_Center;
        mapping(address => bool) public Certificate_Agency;
        mapping(address => bool) public Customer;

        mapping(address => bool) public AllEntities;

        event RegisterationSCDeployed(address , string );
        event ManafactureRegistered(address ,string );
        event CenterRegistered(address,string );
        event AgencyRegistered(address,string);
        event CustomerRegistered(address,string);

        modifier onlyFDA() {
            require(FDA== msg.sender, "Only FDA can use this function");
            _;
        }

        constructor()  {
            FDA = msg.sender;
            emit RegisterationSCDeployed(FDA,"Registeration SC Deployed");
        }

        function isOwner(address o) view public returns (bool){
        return(o==FDA);
        }

        function ManfactureRegisteration(address user) public onlyFDA {
            require(!Manafacture[user], "The user is already Registered");
            Manafacture[user] = true;
            AllEntities[user] = true;
            emit ManafactureRegistered(user,"New Manafacture Registered");
        }

        function CenterRegisteration(address user) public onlyFDA {
            require(!Refurbishment_Center[user], "The user is already Registered");
            Refurbishment_Center[user] = true;
            AllEntities[user] = true;
            emit CenterRegistered(user,"New Refurbishment Center Registered");
        }

        function AgencyRegisteration(address user) public onlyFDA {
            require(!Certificate_Agency[user], "The user is already Registered");
            Certificate_Agency[user] = true;
            AllEntities[user] = true;
            emit AgencyRegistered(user,"New Certificate Agency Registered");
        }

        function CustomerRegisteration(address user) public onlyFDA {
            require(!Customer[user], "The user is already Registered");
            Customer[user] = true;
            AllEntities[user] = true;
            emit CustomerRegistered(user,"New Customer Registered");
        }

}
// File: Trading.sol




pragma solidity ^0.8.18;



contract Trading is AutomationCompatibleInterface, ReentrancyGuard {

    Registration immutable RContract; //access varaibles from registration contract

    address payable public owner;
    address payable public renter;


    string public ipfsDeviceHash;
    string public ipfsCertHash;
    
    uint public price;
    uint public rentPrice;
    uint public SD_Price;
    uint Duration;
    uint startTime;

    bool public auctionstart = false;
    bool public availableforSale = false;
    bool public rented = false;
    bool public timerOn = false;

    struct requesters{
        address payable customer;
        uint amount;  
    }

    uint numOfRequesters = 0;
    mapping(uint => requesters) public listofCustomers;
    
    constructor(string memory DeviceHash, uint devicePrice,address reg) {
        owner = payable(msg.sender);
        ipfsDeviceHash = DeviceHash;
        price = devicePrice;
        RContract = Registration(reg);
    }


    event certRequested(address , string );
    event deviceAvailable(address , string , string , string  , uint , uint , uint );
    event newPurchaseRequest(address , string , string );
    event endTimer(string );
    event purchaseRequestAccepted(address , string , string ,uint );
    event auctionStarted(address , string ,string , string ,uint , uint );
    event newBidPlaced(address , string  ,uint , string );
    event auctionEnded(address , string ,string , address , uint );
    event newRentRequest(address , string , uint );
    event rentRequestAccepted(address , string , string ,uint );
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAgency{
        require(RContract.Certificate_Agency(msg.sender), "Only Registered Certificate Agency can execute this function");
        _;
    }

    modifier onlyCustomers{
        require(RContract.Customer(msg.sender), "Only Customer can execute this function");
        _;
    }

    function requestCert() public onlyOwner {
        emit certRequested(msg.sender,ipfsDeviceHash);
    }

    function setCertHash(string memory CertHash) public onlyAgency{
        ipfsCertHash = CertHash;
    }

    function setDeviceHash(string memory CertHash) public onlyOwner{
        ipfsDeviceHash = CertHash;
    }

    function offerForSale(uint _price, uint _rentPrice, uint _sdPrice) public onlyOwner {
        availableforSale = true;
        price = _price;
        rentPrice = _rentPrice;
        SD_Price = _sdPrice;
        emit deviceAvailable(owner, "New Device Available for Sale", ipfsDeviceHash, ipfsCertHash, price, rentPrice, SD_Price);
    }

    function purchaseRequest() public payable onlyCustomers nonReentrant{
        require(availableforSale, "Equipment is not avaialble for sale");
        require(!auctionstart);
        require(msg.value==price, "Wrong amount sent");
        emit newPurchaseRequest(msg.sender, "New Purchase Request", ipfsDeviceHash);
        listofCustomers[numOfRequesters].customer = payable(msg.sender);
        listofCustomers[numOfRequesters].amount = msg.value;
        numOfRequesters +=1;
    }

    function returnPurchaseRequests() public onlyOwner nonReentrant{
        uint256 numreq = numOfRequesters;
        numOfRequesters = 0;
        for(uint i =0; i<numreq; i++){
            uint256 amt = listofCustomers[i].amount;
            address payable adr = listofCustomers[i].customer;
            listofCustomers[i].customer=payable(0);
            listofCustomers[i].amount=0;
            transfer(adr, amt);
        }
    }

    function startTimer(uint t) public onlyOwner nonReentrant{
        Duration = t;
        timerOn = true;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (((startTime+Duration) < block.timestamp) && (auctionstart || rented || timerOn)) ;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if (((startTime+Duration) < block.timestamp) && (auctionstart || rented || timerOn)) {
        //emit endTimer("Timer Ended");
            if (auctionstart){
                emit endTimer("Auction Ended"); 
                auctionstart = false;
            } else if(rented){
                emit endTimer("Rent Duration Ended");
                rented = false;
            } else{
                emit endTimer("Timer Ended");
                timerOn=false;
            }
        }
        // We don't use the performData in this example. The performData is generated by the Automation Node's call to your checkUpkeep function
    }

    function _purchaseRequestAccepted() public onlyOwner nonReentrant{
        uint256 amt = listofCustomers[0].amount;
        emit purchaseRequestAccepted(listofCustomers[0].customer, "Purchase Request Accepted", ipfsDeviceHash,listofCustomers[0].amount);
        listofCustomers[0].amount=0;
        owner = listofCustomers[0].customer;
        numOfRequesters = 0;
        listofCustomers[0].customer=payable(0);
        availableforSale = false;
        transfer(owner, amt);

    }

    function startAuction(uint t) public onlyOwner{
        require(availableforSale==true);
        require(!rented);
        auctionstart = true;
        Duration = t;
        startTime = block.timestamp;
        returnPurchaseRequests();
        emit auctionStarted(msg.sender, "New Auction started",ipfsDeviceHash, ipfsCertHash,price, t);
    }

    function placeBid() public payable onlyCustomers nonReentrant{
        uint256 amt = listofCustomers[0].amount;
        require (auctionstart == true);
        require (msg.value > listofCustomers[0].amount);
        emit newBidPlaced(msg.sender, "New Bid Placed",msg.value, ipfsDeviceHash);
        listofCustomers[0].amount = msg.value;
        listofCustomers[0].customer = payable(msg.sender);
        transfer(payable(msg.sender), amt);
    }

    function auctionClosed() public onlyOwner nonReentrant{
        uint256 amt = listofCustomers[0].amount;
        require(!auctionstart);
        emit auctionEnded(msg.sender, "Auction Ended", ipfsDeviceHash, listofCustomers[0].customer,listofCustomers[0].amount);
        owner = listofCustomers[0].customer;
        listofCustomers[0].customer=payable(0);
        listofCustomers[0].amount=0;
        availableforSale = false;
        transfer(owner, amt);

    }

    function transfer(address payable _to, uint _amount) private  nonReentrant{
        // Note that "to" is declared as payable
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    function rentRequest(uint _rentDuration) public payable onlyCustomers nonReentrant{
        require(availableforSale, "Not available for sale");
        require(!auctionstart, "Equipment is in an Auction, cant be rented");
        require(!rented);
        require(msg.value==(rentPrice*_rentDuration+SD_Price),"Incorrect amount");
        Duration = _rentDuration;
        renter = payable(msg.sender);
        emit newRentRequest(msg.sender, "New Rent Request",_rentDuration);
    }

    function _rentRequestAccepted() public onlyOwner nonReentrant{
        emit rentRequestAccepted(renter, "Rent Request Accepted", ipfsDeviceHash,Duration);
        availableforSale = false;
        rented = true;
        startTime = block.timestamp;
        transfer(owner, rentPrice*Duration);
    }

    function recievedEquipment(uint reductionPrice) public onlyOwner nonReentrant{
        address payable adr = renter;
        require(reductionPrice <= SD_Price,"Requested higher than Security Deposit");
        renter = payable(0);
        Duration = 0;
        rented = false;
        transfer(owner, reductionPrice);
        transfer(adr, SD_Price-reductionPrice);
    }

}