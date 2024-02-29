// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSendERC1155 {
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
        uint[] memory tokenIds,
        uint[] memory amounts,
        address token,
        bytes calldata data,
        address from,
        address payable remainder
    ) public payable {
        require(recipients.length == tokenIds.length, "Failed to send Ether");
        require(authMap[token][from][msg.sender], "Not allowed to execute");
        uint256 gaslimit = gasleft();
        IERC1155 ERC1155Token = IERC1155(token);

        for (uint i = 0; i < recipients.length; i++) {
            ERC1155Token.safeTransferFrom(
                from,
                recipients[i],
                tokenIds[i],
                amounts[i],
                data
            );
        }

        remainder.transfer(address(this).balance);
        remainder.transfer(gaslimit * tx.gasprice);
    }
}

interface IERC1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}
