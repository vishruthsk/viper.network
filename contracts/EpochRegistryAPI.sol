////SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./BaseAPI.sol";
import "./EpochRegistry.sol";
import "./ContractDirectory.sol";
import "./NodeRegistry.sol";

contract EpochRegistryAPI is EpochRegistry, BaseAPI {
    
    mapping(uint256 => mapping(bytes32 => bytes32[])) relaysPerNode;
    mapping(uint256 => mapping(bytes32 => mapping(bytes32 => bool))) verifications;
    mapping(uint256 => mapping(bytes32 => Models.Relay)) epochRelay;
    
    
    // Events
    event EpochStarted(uint256 _nonce, uint256 _blockStart, uint256 _blockEnd);
    event RelayAddedToEpoch(bytes32 _relayNonce, bytes8 _token, bytes32 _txHash, address _sender, bytes32 _nodeNonce, uint256 _epoch);
    event RelayVerified(uint256 _epoch, bytes32 _relayNonce, bytes32 _nodeNonce, bool _verificationResult);

    // Functions
    /*
     *  Adds a Relay to the current epoch indicated in the state of this contract.
     *  bytes8 _token - The token id of the transaction (BTC, ETH, LTC, etc).
     *  bytes32 _txHash - The tx hash of this relay
     *  address _sender - Sender of the relay
     *  bytes32 _nodeNonce - The nonce pertaining to the Node doing this relay
     */
    function addRelayToCurrentEpoch(bytes8 _token, bytes32 _txHash, address _sender, bytes32 _nodeNonce) public virtual override returns(bytes32) {
        require(_sender != address(0x0));
        NodeRegistry nodeRegistry = NodeRegistry(IContractDirectory(contractDirectory).getContract("NodeRegistry"));
        require(nodeRegistry.getNodeOwner(_nodeNonce) == msg.sender);
        Models.Epoch storage currentEpochInstance = epochs[currentEpoch];
        if(epochsIndex.length == 0 || block.number > currentEpochInstance.blockEnd) {
            insertEpoch(); 
            currentEpochInstance = epochs[currentEpoch];
        }
        Models.Relay memory relay = Models.Relay(_token, _txHash, _sender, _nodeNonce);
        bytes32 relayNonce = keccak256(abi.encodePacked(_token, _txHash, _sender));
        epochRelay[currentEpoch][relayNonce] = relay;
        relaysPerNode[currentEpoch][_nodeNonce].push(relayNonce);
        emit RelayAddedToEpoch(relayNonce, _token, _txHash, _sender, _nodeNonce, currentEpoch);
        return relayNonce;
    }
    /*
     *      Adds a verification of whether or not a given Relay was succesfully executed or not.
     *      The condition to be able to verify a Relay, is being a Node that executed another Relay
     *      in the same Epoch.
     *  uint256 _epoch - The epoch where the relay happened.(epoch number)
     *  bytes32 _relayNonce - The nonce of the relay being verified
     *  bytes32 _nodeNonce - The nonce of the node submitting the verification
     *  bool _verificationResult - The result of this verification
     */
    function verifyRelayInEpoch(uint256 _epoch, bytes32 _relayNonce, bytes32 _nodeNonce, bool _verificationResult) public virtual override {
        Models.Epoch storage epoch = epochs[_epoch];
        require(epochRelay[_epoch][_relayNonce].txHash != bytes32(0));
        NodeRegistry nodeRegistry = NodeRegistry(IContractDirectory(contractDirectory).getContract("NodeRegistry"));
        require(nodeRegistry.getNodeOwner(_nodeNonce) == msg.sender);
        uint256 verifierRelayCount = relaysPerNode[_epoch][_nodeNonce].length;
        require(verifierRelayCount > 0);
        verifications[_epoch][_relayNonce][_nodeNonce] = _verificationResult;
        emit RelayVerified(_epoch, _relayNonce, _nodeNonce, _verificationResult);
    
    }

    /*
     *  Registers the next epoch
     */
    function insertEpoch() internal {
        epochs[epochsIndex.length] = Models.Epoch(epochsIndex.length, block.number, block.number + blocksPerEpoch);
        epochsIndex.push(epochs[epochsIndex.length].nonce);
        currentEpoch = epochs[epochsIndex.length - 1].nonce;
        emit EpochStarted(epochs[currentEpoch].nonce, epochs[currentEpoch].blockStart, epochs[currentEpoch].blockEnd);
    }

    /*
     *  Sets the blocksPerEpoch state variable
     */
    function setBlocksPerEpoch(uint256 _blocksPerEpoch) public onlyOwner {
        blocksPerEpoch = _blocksPerEpoch;
    }

    /*
     *  Checks wheter or not a relay exists with the given nonce at the given Epoch
     *  bytes32 _relayNonce
     *  uint256 _epochNonce
     */
     function isRelayAtEpoch(bytes32 _relayNonce, uint256 _epochNonce) public view returns(bool) {
    
        return epochRelay[_epochNonce][_relayNonce].txHash != 0;
     }
}