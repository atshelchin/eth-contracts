// SPDX-License-Identifier: MIT
// solc 0.8.19
// evmVersion paris
// optimizer 200

pragma solidity ^0.8.9;
pragma abicoder v2;

contract Tokensender {
    function sendETH(address recipient, uint256 amount) public payable {
        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function sendERC20(
        address recipient,
        uint256 amount,
        address token
    ) public {
        IERC20 ERC20Token = IERC20(token);
        ERC20Token.transferFrom(msg.sender, recipient, amount);
    }

    function sendERC721(
        address recipient,
        uint256 tokenId,
        address token
    ) public {
        IERC721 ERC721Token = IERC721(token);
        ERC721Token.safeTransferFrom(msg.sender, recipient, tokenId);
    }

    function sendERC1155(
        address recipient,
        uint256 tokenId,
        uint256 amount,
        address token,
        bytes calldata data
    ) public {
        IERC1155 ERC1155Token = IERC1155(token);
        ERC1155Token.safeTransferFrom(
            msg.sender,
            recipient,
            tokenId,
            amount,
            data
        );
    }

    function multicall(
        bytes[] calldata data
    ) public payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(
                data[i]
            );

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
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
