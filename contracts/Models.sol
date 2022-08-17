//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Models {

    struct Relay {
        bytes8 token;
        bytes32 txHash;
        address sender;
        bytes32 nodeNonce;
        
    }

    struct Epoch {
        uint256 nonce;
        uint256 blockStart;
        uint256 blockEnd;
    }

    struct Node {
        bytes32 nonce;
        address owner;
        bytes8[] networks;
        string endpoint;
    }

}