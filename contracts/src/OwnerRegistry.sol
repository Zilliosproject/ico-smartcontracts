pragma solidity ^0.4.17;

import "./PropertyOwner.sol";

contract OwnerRegistry {
    mapping (address => bool) private ownersExist;
    mapping (address => PropertyOwner) private owners;
    uint256 private countOwners;

    function OwnerRegistry() public payable {
        countOwners = 0;

        //baseline data
        /*registerOwner(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, "sergio", 1);
        registerOwner(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, "eduardo", 1);
        registerOwner(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db, "alberto", 1);
        registerOwner(0x583031d1113ad414f02576bd6afabfb302140225, "junior", 1);
        registerOwner(0xdd870fa1b7c4700f2bd7f44238821c26f7392148, "bas", 1);*/
    }

    function registerOwner(address ownerAddress, string ownerName) public returns (bool) {
        if (!ownerExists(ownerAddress)) {
            owners[ownerAddress] = new PropertyOwner(ownerAddress, ownerName, 1);
            ownersExist[ownerAddress] = true;
            countOwners++;
            return true;
        }
        else {
            return false;
        }
    }

    function getOwner(address ownerAddress) public returns (PropertyOwner) {
        return owners[ownerAddress];
    }

    function ownerExists(address ownerAddress) public returns (bool) {
        return ownersExist[ownerAddress] == true;
    }

    function howManyOwners() public returns (uint256) {
        return countOwners;
    }
}
