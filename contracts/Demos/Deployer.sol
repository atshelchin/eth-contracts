// SPDX-License-Identifier: MIT
// solc 0.8.19
// evmVersion paris
// optimizer 200

pragma solidity ^0.8.19;

contract Deployer {
    event Deployed(address addr, address namespace, uint salt);

    function getAddress(
        bytes memory bytecode,
        address namespace,
        uint salt
    ) public view returns (address) {
        bytes32 newSalt = keccak256(abi.encodePacked(salt, namespace));
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                newSalt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint(hash)));
    }

    function deploy(
        bytes memory bytecode,
        bool isPublicNamespace,
        uint salt
    ) public payable returns (address addr) {
        address namespace = address(0);
        if (!isPublicNamespace) {
            namespace = msg.sender;
        }
        bytes32 newSalt = keccak256(abi.encodePacked(salt, namespace));
        assembly {
            addr := create2(
                callvalue(),
                add(bytecode, 0x20),
                mload(bytecode),
                newSalt
            )

            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
        emit Deployed(addr, namespace, salt);
    }
}
