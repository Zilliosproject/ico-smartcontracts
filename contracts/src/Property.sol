pragma solidity ^0.4.17;

import "./PropertyRegistry.sol";

/*
 * Defines a Property and its state
 */
contract Property {
    address private owner;

    PropertyRegistry propertyRegistry;

    struct PropertyState {
        address propertyAddress;
        address propertyOwnerAddress;
        address propertyAgentAddress;
        string propertyHash;
        uint256 timestamp;
        address lastUpdatedBy;
    }

    PropertyState private currentState;
    mapping (uint256 => PropertyState) private changeLog;
    uint256 private countUpdates;

    mapping(address => bool) private agentsInvolved;
    uint256 countAgentsInvolved;

    mapping(address => bool) private pendingRequests;
    uint256 countPendingRequests;

    event OnChange(string eventId, string eventDescriptor);

    function Property(address _propertyAddress, address _ownerAddress, address _agentAddress, string _propertyHash) public {
        //"0xbfd5b36fa6f5de48d807397e9b68d0a0d694e38e"
        propertyRegistry = new PropertyRegistry();
        //require (propertyRegistry.actorExists(msg.sender));

        Property property;
        if (propertyRegistry.propertyExists(_propertyAddress)) {
            property = propertyRegistry.getProperty(_propertyAddress);
        }
        else {
            agentsInvolved[msg.sender] = true;
            countAgentsInvolved = 1;
            countPendingRequests = 0;

            currentState.propertyAddress = _propertyAddress;
            currentState.propertyOwnerAddress = _ownerAddress;
            currentState.propertyAgentAddress = _propertyAddress;
            currentState.propertyHash = _propertyHash;
            currentState.timestamp = 0;
            currentState.lastUpdatedBy = msg.sender;

            countUpdates = 0;
            changeLog[countUpdates++] = currentState;

            property = this;
            propertyRegistry.registerProperty(_propertyAddress, this);
        }
    }

    function addAgent(address agentAddress) public returns (bool) {
        require (owner == msg.sender);

        if (agentsInvolved[agentAddress] == false) {
            agentsInvolved[agentAddress] = true;
            countAgentsInvolved++;
            return true;
        }
        else {
            return false;
        }
    }

    function removeAgent(address agentAddress) public returns (bool) {
        //require (owner == msg.sender && propertyRegistry.actorExists(agentAddress));

        if (agentsInvolved[agentAddress] == true) {
            agentsInvolved[agentAddress] = false;
            return true;
        }
        else {
            return false;
        }
    }

    function requestInvolvement(address agentAddress) public {
        //require (propertyRegistry.actorExists(msg.sender));

        //pendingRequests[msg.sender] = true;
        pendingRequests[agentAddress] = true;
        countPendingRequests++;
    }

    function approveInvolvementRequest(address addressToApprove) public returns (bool) {
        //require (owner == msg.sender);

        if (pendingRequests[addressToApprove] == true) {
            agentsInvolved[addressToApprove] = true;
            pendingRequests[addressToApprove] = false;
            countPendingRequests--;
            return true;
        }
        else {
            return false;
        }
    }

    function transferOwnership(address newOwnerAddress) public returns (bool) {
        //require (owner == msg.sender);

        if (agentsInvolved[msg.sender] == true) {
            updateProperty(currentState.propertyAddress, newOwnerAddress, currentState.propertyAgentAddress, currentState.propertyHash);
            return true;
        }
        else {
            return false;
        }
    }

    function updateProperty(address newPropertyAddress, address newPropertyOwnerAddress, address newPropertyAgentAddress, string newPropertyHash) public returns (bool) {
        //require(propertyRegistry.actorExists(msg.sender));

        PropertyState storage newState;
        newState.propertyAddress = newPropertyAddress;
        newState.propertyOwnerAddress = newPropertyOwnerAddress;
        newState.propertyAgentAddress = newPropertyAgentAddress;
        newState.propertyHash = newPropertyHash;
        newState.timestamp = 0;
        newState.lastUpdatedBy = msg.sender;

        changeLog[countUpdates++] = newState;

        //OnChange(newPropertyAddress, newPropertyOwnerAddress, newPropertyAgentAddress, newPropertyHash);
    }

    function isAgentOwner(address agentAddress) public returns (bool) {
        return owner == agentAddress;
    }

    function isAgentInvolved(address agentAddress) public returns (bool) {
        return agentsInvolved[agentAddress] == true;
    }

    function howManyAgentsInvolved() public returns (uint256) {
        return countAgentsInvolved;
    }

    function isAgentPendingApproval(address agentAddress) public returns (bool) {
        return pendingRequests[agentAddress] == true;
    }

    function howManyPendingRequests() public returns (uint256) {
        return countPendingRequests;
    }

    function howManyUpdates() public returns (uint256) {
        return countUpdates;
    }

    function getPropertyOwner() public returns (address) {
        return currentState.propertyOwnerAddress;
    }

    function getPropertyHash() public returns (string) {
        return currentState.propertyHash;
    }

    function getPropertyLastAuthor() public returns (address) {
        return currentState.lastUpdatedBy;
    }
}
