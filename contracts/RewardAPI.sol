//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./EpochRegistryAPI.sol";
import "./ContractDirectory.sol";
import "./NodeRegistry.sol";
import "./VIPER.sol";
import "./ViperGeyser.sol";


contract RewardAPI is EpochRegistryAPI{
    ViperGeyser token;
    VIPER viper;
    uint256 reward = 1;
    bytes32 merkleRoot;
    address owner;

    mapping(uint256 => mapping(bytes32 => mapping(bytes32 => bool))) rewardClaimed;
    //Events
    event RelayValidated(uint256 _epoch, bytes32 _relayNonce, bytes32 _nodeNonce);
    event RelayRewardClaimed(bytes32 _nodeNonce,string message);
    event OwnerBalanceWithdrawn(bytes32 _nodeNonce, uint _balanceWithdrawn);
    //Function
    /* allows to Submit Proof, which would be validated 
     *  uint256 _epoch - The epoch where the relay happened.
     *  bytes32 _relayNonce - The nonce of the relay being verified
     *  bytes32 _nodeNonce - The nonce of the node submitting the verification
     *  bytes32[] memory _proof - merkle proof submitted for verification
     */
    function submitProof(uint256 _epoch, bytes32 _relayNonce, bytes32 _nodeNonce, bytes32[] memory _proof) public{
        require(epochRelay[_epoch][_relayNonce].txHash != bytes32(0));
        NodeRegistry nodeRegistry = NodeRegistry(IContractDirectory(contractDirectory).getContract("NodeRegistry"));
        address _node = nodeRegistry.getNodeOwner(_nodeNonce);
        require(_node == msg.sender);
        bytes32 _leaf = keccak256(abi.encodePacked(_epoch,_relayNonce,_nodeNonce));
        bool verify = MerkleProof.verify(_proof, merkleRoot, _leaf);
        if(verify==true){
            
            verifyRelayInEpoch(_epoch, _relayNonce, _nodeNonce, verify);
            // Emit event
            emit RelayValidated(_epoch, _relayNonce, _nodeNonce);
            // Mint reward
            claimReward(_epoch,_nodeNonce, _relayNonce);

        }else{
            viper.burn(_node, 0.1 * _proof.length);
        }
    }

    /* Claims the relay reward, if not already claimed 
     *  uint256 _epoch - The epoch where the relay happened.
     *  bytes32 _relayNonce - The nonce of the relay being verified
     *  bytes32 _nodeNonce - The nonce of the node submitting the verification
    */
    function claimReward(uint256 _epoch, bytes32 _nodeNonce, bytes32 _relayNonce) internal{
        require(token.totalStakedFor(msg.sender) > 10000);
        require(!rewardClaimed[_epoch][_nodeNonce][_relayNonce]);
        uint256 previousEpoch = epochs[epochsIndex.length - 1].nonce;
        require(block.number > epochs[previousEpoch].blockEnd);
        NodeRegistry nodeRegistry = NodeRegistry(IContractDirectory(contractDirectory).getContract("NodeRegistry"));
        address _node = nodeRegistry.getNodeOwner(_nodeNonce);
        uint256 relayServed = relaysPerNode[previousEpoch][_nodeNonce].length;
        viper.mint(_node,reward*relayServed);
        emit RelayRewardClaimed(_nodeNonce, "Reward Claimed");

    } 
   /*  withdraw balance from nodes account
    *  bytes32 _nodeNonce - The nonce of the node submitting the verification
    */
    function withdrawBalance(bytes32 _nodeNonce) public{
        NodeRegistry nodeRegistry = NodeRegistry(IContractDirectory(contractDirectory).getContract("NodeRegistry"));
        require(nodeRegistry.getNodeOwner(_nodeNonce) == msg.sender);
        address _node = nodeRegistry.getNodeOwner(_nodeNonce);
        uint balance = _node.balance;
        // Check if there's any balance to withdraw
        require(balance > 0);

        // Transfer balance
        (bool sent,)= _node.call{value: balance}("");
        sent= true;

        // Zero out the current owner balance
        balance = 0;

        // Emit event
        emit OwnerBalanceWithdrawn(_nodeNonce, balance);
    }

     function getNodeBalance(bytes32 _nodeNonce) public view returns (uint) {
        NodeRegistry nodeRegistry = NodeRegistry(IContractDirectory(contractDirectory).getContract("NodeRegistry"));
        address _node = nodeRegistry.getNodeOwner(_nodeNonce);
        return _node.balance;
    }


}