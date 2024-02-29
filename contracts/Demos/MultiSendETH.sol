// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSendETH {
    constructor(
        address[] memory recipients,
        uint[] memory amounts,
        address remainder
    ) payable {
        require(recipients.length == amounts.length, "Failed to send Ether");

        for (uint i = 0; i < recipients.length; i++) {
            sendETH(recipients[i], amounts[i]);
        }

        sendETH(remainder, address(this).balance);
    }

    function sendETH(address recipient, uint256 amount) public payable {
        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Failed to send Ether");
    }
}
