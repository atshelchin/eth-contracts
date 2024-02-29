// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSendETH2 {
    constructor(
        address payable[] memory recipients,
        uint[] memory amounts,
        address payable remainder
    ) payable {
        require(recipients.length == amounts.length, "Failed to send Ether");

        for (uint i = 0; i < recipients.length; i++) {
            (recipients[i]).transfer(amounts[i]);
        }

        remainder.transfer(address(this).balance);
    }
}
