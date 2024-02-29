// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ETHSender {
    function execute(
        address payable[] memory recipients,
        uint256[] memory amounts,
        address payable remainder
    ) public payable {
        precheck(
            recipients.length,
            amounts.length,
            "Failed to send Ether",
            remainder
        );
        for (uint i = 0; i < recipients.length; i++) {
            (recipients[i]).transfer(amounts[i]);
        }
    }

    function precheck(
        uint256 len1,
        uint256 len2,
        string memory message,
        address payable remainder
    ) internal {
        uint256 gaslimit = gasleft();
        require(len1 == len2, message);
        uint256 fee = gaslimit * tx.gasprice;
        require(msg.value >= fee, "Insufficient fee");
        remainder.transfer(fee);
    }
}
