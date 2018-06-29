pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/src/Property.sol";
import "../contracts/src/PropertyOwner.sol";
import "../contracts/src/PropertyAgent.sol";
import "../contracts/src/PropertyRegistry.sol";
import "../contracts/src/OwnerRegistry.sol";
import "../contracts/src/AgentRegistry.sol";

contract TestPropertyOperations {

    address propertyRegistry;// = 0x345ca3e014aaf5dca488057592ee47305d9b3e10;//got it from PropertyRegistry.json
    address ownerRegistry;// = 0xf17f52151ebef6c7334fad080c5704d77216b732;//got it from OwnerRegistry.json
    address agentRegistry;// = 0xc5fdf4076b8f3a5357c5e395ab970b5b54098fef;//got it from AgentRegistry.json

    // Test Data
    address propertyAddress1 = 0x0000000000000000000000000000000000000001;
    string propertyHash1 = "DummyHash1";
    address propertyAddress2 = 0x0000000000000000000000000000000000000002;
    string propertyHash2 = "DummyHash2";
    address propertyAddress3 = 0x0000000000000000000000000000000000000003;
    string propertyHash3 = "DummyHash3";

    address ownerAddress1 = 0x0000000000000000000000000000000000000011;
    string ownerName1 = "Joe Cane";
    address ownerAddress2 = 0x0000000000000000000000000000000000000012;
    string ownerName2 = "Mike Phillips";
    address ownerAddress3 = 0x0000000000000000000000000000000000000013;
    string ownerName3 = "David Stone";

    address agentAddress1 = 0x0000000000000000000000000000000000000021;
    string agentName1 = "Sarah Parker";
    address agentAddress2 = 0x0000000000000000000000000000000000000022;
    string agentName2 = "Mary Drew";
    address agentAddress3 = 0x0000000000000000000000000000000000000023;
    string agentName3 = "Jane Williams";

    function test() public {
        propertyRegistry = new PropertyRegistry();
        ownerRegistry = new OwnerRegistry();
        agentRegistry = new AgentRegistry();

        //Test creation of Owner1
        ownerRegistry.registerOwner(ownerAddress1, ownerName1);
        Assert.isTrue(ownerRegistry.ownerExists(ownerAddress1), "Owner1 is registered.");

        //Test creation of Agent1
        agentRegistry.registerAgent(agentAddress1, agentName1);
        Assert.isTrue(agentRegistry.agentExists(agentAddress1), "Agent1 is registered.");

        //Test creation of Property1 (with Owner1 and Agent1)
        Property property1 = new Property(propertyAddress1, ownerAddress1, agentAddress1, propertyHash1);
        Assert.isTrue(property1.isOwner(ownerAddress1), "Owner1 owns Property1.");
        Assert.isTrue(property1.isAgent(agentAddress1), "Agent1 is authorized to be Property1''s agent.");
        Assert.isTrue(propertyRegistry.propertyExists(propertyAddress1), "Property1 is registered.");

        //Test changing Property1''s agent to Agent2
        agentRegistry.registerAgent(agentAddress2, agentName2);
        Assert.isTrue(agentRegistry.agentExists(agentAddress1), "Agent1 is registered.");
        property1.addAgent(agentAddress2);
        property1.removeAgent(agentAddress1);
        Assert.isFalse(property1.isAgent(agentAddress1), "Agent1 is not authorized to be Property1''s agent anymore.");
        Assert.isTrue(property1.isAgent(agentAddress2), "Agent2 is authorized to be Property1''s agent.");

        //Test selling Property1 to Owner2
        ownerRegistry.registerOwner(ownerAddress2, ownerName2);
        Assert.isTrue(ownerRegistry.ownerExists(ownerAddress1), "Owner2 is registered.");
        property1.transferOwnership(ownerAddress2);
        Assert.isFalse(property1.isOwner(ownerAddress1), "Owner1 doesn''t own Property1 anymore.");
        Assert.isTrue(property1.isOwner(ownerAddress2), "Owner2 owns Property1.");
    }
}
