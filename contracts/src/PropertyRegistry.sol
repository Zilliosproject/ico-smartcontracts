pragma solidity ^0.4.17;

import "./Property.sol";
import "./OwnerRegistry.sol";
import "./AgentRegistry.sol";

contract PropertyRegistry {
    OwnerRegistry ownerRegistry;
    AgentRegistry agentRegistry;

    mapping (address => bool) private propertiesExist;
    mapping (address => Property) private properties;
    uint256 private countProperties;

    function PropertyRegistry() public payable {
        countProperties = 0;

        //baseline data
        /*registerProperty(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, "sergio", 1);
        registerProperty(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, "eduardo", 1);
        registerProperty(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db, "alberto", 1);
        registerProperty(0x583031d1113ad414f02576bd6afabfb302140225, "junior", 1);
        registerProperty(0xdd870fa1b7c4700f2bd7f44238821c26f7392148, "bas", 1);*/
    }

    function registerProperty(address propertyAddress, Property property) public returns (bool) {
        if (!propertyExists(propertyAddress)) {
            properties[propertyAddress] = property;
            propertiesExist[propertyAddress] = true;
            countProperties++;
            return true;
        }
        else {
            return false;
        }
    }

    function getProperty(address propertyAddress) public returns (Property) {
        return properties[propertyAddress];
    }

    function propertyExists(address propertyAddress) public returns (bool) {
        return propertiesExist[propertyAddress] == true;
    }

    function howManyProperties() public returns (uint256) {
        return countProperties;
    }
}
