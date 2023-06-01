// SPDX-License-Identifier: MIT

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
// File: Reputation.sol



pragma solidity ^0.8.18;



contract Reputation{
    
    Registration immutable RContract;

    struct EntityRep{
        //address entity;
        bool state;
        uint Totalscore;
        uint AverageScore;
        uint numberOfFeedback;
        mapping(address => bool) Feedbackers;
    }
    mapping(address => EntityRep) public Rep;
    
    address immutable owner;

    constructor(address reg) {
        RContract = Registration(reg);
        require(RContract.isOwner(msg.sender), "Not Authorized to Deploy Contract");
        owner = msg.sender;
    }

    function rateEntity(address entity, uint score) public {
        require(RContract.AllEntities(entity),"Entity is not Registered by FDA");
        require(!Rep[entity].Feedbackers[msg.sender],"Already rated the entity");
        require(score<=5,"Score value should be between 0 and 5");
        Rep[entity].Totalscore +=score;
        Rep[entity].numberOfFeedback +=1;
        Rep[entity].Feedbackers[msg.sender] =true;
        Rep[entity].AverageScore=Rep[entity].Totalscore/Rep[entity].numberOfFeedback;
    }

    function getRep(address entity) public view returns(uint){
        require(RContract.AllEntities(entity),"Entity is not Registered by FDA");
        return  Rep[entity].AverageScore;
    }


}