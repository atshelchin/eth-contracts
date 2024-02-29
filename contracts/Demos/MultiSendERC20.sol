// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSendERC20 {
    mapping(address => mapping(address => mapping(address => bool)))
        public authMap;

    function grant(address token, address[] memory list) public {
        for (uint i = 0; i < list.length; i++) {
            authMap[token][msg.sender][list[i]] = true;
        }
    }

    function revoke(address token, address[] memory list) public {
        for (uint i = 0; i < list.length; i++) {
            authMap[token][msg.sender][list[i]] = false;
        }
    }

    function execute(
        address payable[] memory recipients,
        uint[] memory amounts,
        address token,
        address from,
        address payable remainder
    ) public payable {
        require(recipients.length == amounts.length, "Failed to send Ether");
        require(authMap[token][from][msg.sender], "Not allowed to execute");
        uint256 gaslimit = gasleft();
        IERC20 ERC20Token = IERC20(token);

        for (uint i = 0; i < recipients.length; i++) {
            ERC20Token.transferFrom(from, recipients[i], amounts[i]);
        }

        // remainder.transfer(address(this).balance);
        remainder.transfer(gaslimit * tx.gasprice);
    }
}

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
