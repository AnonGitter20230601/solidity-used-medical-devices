// SPDX-License-Identifier: MIT

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