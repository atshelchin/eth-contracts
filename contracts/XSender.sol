// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract XSender {
    mapping(address => mapping(address => bool)) public whiteList;
    mapping(address => uint256) public balance;

    modifier onlyAuthorized(address source) {
        require(whiteList[source][msg.sender], "Not authorized");
        _;
    }

    function sendETH(
        address payable[] memory recipients,
        uint256[] memory amounts,
        address source,
        address payable remainder
    ) public payable onlyAuthorized(source) {
        precheck(
            recipients.length,
            amounts.length,
            "Failed to send Ether",
            remainder
        );
        for (uint256 i = 0; i < recipients.length; i++) {
            require(balance[source] >= amounts[i], "Insufficient balance");
            (recipients[i]).transfer(amounts[i]);
            balance[source] = balance[source] - amounts[i];
        }
    }

    function sendERC20(
        address token,
        address payable[] memory recipients,
        uint256[] memory amounts,
        address source,
        address payable remainder
    ) public payable onlyAuthorized(source) {
        precheck(
            recipients.length,
            amounts.length,
            "Failed to send ERC20",
            remainder
        );
        IERC20 ERC20Token = IERC20(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            ERC20Token.transferFrom(source, recipients[i], amounts[i]);
        }
    }

    function sendERC721(
        address token,
        address payable[] memory recipients,
        uint256[] memory tokenIds,
        address source,
        address payable remainder
    ) public payable onlyAuthorized(source) {
        precheck(
            recipients.length,
            tokenIds.length,
            "Failed to send ERC721",
            remainder
        );
        IERC721 ERC721Token = IERC721(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            ERC721Token.safeTransferFrom(source, recipients[i], tokenIds[i]);
        }
    }

    function sendERC1155(
        address token,
        address payable[] memory recipients,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes calldata data,
        address source,
        address payable remainder
    ) public payable onlyAuthorized(source) {
        precheck(
            recipients.length,
            tokenIds.length,
            "Failed to send ERC1155",
            remainder
        );
        IERC1155 ERC1155Token = IERC1155(token);
        for (uint256 i = 0; i < recipients.length; i++) {
            ERC1155Token.safeTransferFrom(
                source,
                recipients[i],
                tokenIds[i],
                amounts[i],
                data
            );
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

    function deposit() public payable {
        balance[msg.sender] = balance[msg.sender] + msg.value;
    }

    function grant(address[] memory users) public {
        for (uint i = 0; i < users.length; i++) {
            whiteList[msg.sender][users[i]] = true;
        }
    }

    function revoke(address[] memory users) public {
        for (uint i = 0; i < users.length; i++) {
            whiteList[msg.sender][users[i]] = false;
        }
    }

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
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
