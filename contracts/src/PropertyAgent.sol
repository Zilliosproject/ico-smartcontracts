pragma solidity ^0.4.17;

contract PropertyAgent {
    address private id;
    string private name;
    uint256 private role;

    function PropertyAgent(address _id, string _name, uint256 _role) public {
        id = _id;
        name = _name;
        role = _role;
    }

    function isThisPropertyAgent(address idToCompare) public returns (bool) {
        return id == idToCompare;
    }

    function hasThisRole(uint256 roleToCompare) public returns (bool) {
        return role == roleToCompare;
    }

    function getId() public returns (address) {
        return id;
    }

    function getName() public returns (string) {
        return name;
    }

    function getRole() public returns (uint256) {
        return role;
    }
}
