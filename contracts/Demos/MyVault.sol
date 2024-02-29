// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MyVault {
    address public owner;

    mapping(address => bool) public whiteList;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized() {
        require(msg.sender == owner || whiteList[msg.sender], "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {}

    // 此函数用于接收Ether
    receive() external payable {
        deposit();
    }

    // Fallback函数
    fallback() external payable {
        deposit();
    }

    function addToWhiteList(address[] memory users) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = true;
        }
    }

    function removeFromWhiteList(address[] memory users) public onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            whiteList[users[i]] = false;
        }
    }

    function withdraw(uint amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function execute(
        address payable[] memory recipients,
        uint[] memory amounts,
        address payable remainder
    ) public onlyAuthorized {
        require(recipients.length == amounts.length, "Failed to send Ether");
        uint256 gaslimit = gasleft();
        for (uint i = 0; i < recipients.length; i++) {
            (recipients[i]).transfer(amounts[i]);
        }
        remainder.transfer(gaslimit * tx.gasprice);
    }
}
