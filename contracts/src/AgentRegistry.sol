pragma solidity ^0.4.17;

import "./PropertyAgent.sol";

contract AgentRegistry {
    mapping (address => bool) private agentsExist;
    mapping (address => PropertyAgent) private agents;
    uint256 private countAgents;

    function AgentRegistry() public payable {
        countAgents = 0;

        //baseline data
        /*registerAgent(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, "sergio", 1);
        registerAgent(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, "eduardo", 1);
        registerAgent(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db, "alberto", 1);
        registerAgent(0x583031d1113ad414f02576bd6afabfb302140225, "junior", 1);
        registerAgent(0xdd870fa1b7c4700f2bd7f44238821c26f7392148, "bas", 1);*/
    }

    function registerAgent(address agentAddress, string agentName) public returns (bool) {
        if (!agentExists(agentAddress)) {
            agents[agentAddress] = new PropertyAgent(agentAddress, agentName, 1);
            agentsExist[agentAddress] = true;
            countAgents++;
            return true;
        }
        else {
            return false;
        }
    }

    function getAgent(address agentAddress) public returns (PropertyAgent) {
        return agents[agentAddress];
    }

    function agentExists(address agentAddress) public returns (bool) {
        return agentsExist[agentAddress] == true;
    }

    function howManyAgents() public returns (uint256) {
        return countAgents;
    }
}
