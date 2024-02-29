// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSendETH3 {
    function execute(
        address payable[] memory recipients,
        uint[] memory amounts,
        address payable remainder
    ) public payable {
        require(recipients.length == amounts.length, "Failed to send Ether");

        uint256 gaslimit = gasleft();
        for (uint i = 0; i < recipients.length; i++) {
            (recipients[i]).transfer(amounts[i]);
        }

        // AA 钱包 采用 委托调用， adddress(this) 拿到的不是当前合约地址 和是 AA 钱包的地址，执行上下文也变成了AA 钱包，极其危险。
        // remainder.transfer(address(this).balance);
        remainder.transfer(gaslimit * tx.gasprice);
    }
}
