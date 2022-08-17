//SPDX-License-Identifier: UNLICENSED
/* pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./VIPER.sol";

contract Tavern is Ownable, Initializable, AccessControl {
    VIPER viper;
    uint256 Index = 0;
    uint256 reward = 1;
    uint256 lastClaim;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address Relayer;

    function initialize() initializer public {
        require(!initialized);
        initialized = true;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        if(Relayer.balance > 10000){
        _grantRole(MINTER_ROLE, Relayer);
        }
        
    }

    // Relay model
    struct Relay {
        address creator;
        address relayer;
        uint256 index; 
        bytes32 merkleRoot;
        bytes32 leaf;  
        string metadata;
        bool valid;
    }

    mapping(address => uint256[]) validrelay;


    // State
    mapping (address => Relay[]) public relays;
    uint public Balance;
    bool internal initialized;

    // Events
    event RelayCreated(address _relayerAddress, uint _relayIndex);
    event RelayValidated(address _relayerAddress, uint _relayIndex);
    event RelayCompleted(address _relayerAddress, uint _relayIndex, bool succ);
    event RelayRewardClaimed(address _relayer,string message);
    event OwnerBalanceWithdrawn(address _owner, uint _balanceWithdrawn);

    // Creates a new relay
    function createRelay(address _relayer,bytes32 _merkleRoot, string memory _metadata) public returns(bool){
        
        Relay memory newRelay;
        uint256 RelayIndex = Index;
        newRelay.creator = msg.sender;  
        newRelay.relayer = _relayer;
        newRelay.index = RelayIndex ;
        newRelay.merkleRoot = _merkleRoot;
        newRelay.leaf = keccak256(abi.encodePacked(_relayer,RelayIndex));
        newRelay.metadata = _metadata;
        Index +=1;

        // Save Relay
        relays[_relayer].push(newRelay);

        // Emit event
        emit RelayCreated(_relayer, RelayIndex);

        // Validate relay
        validateRelay(_relayer, RelayIndex);
        return true;
    }

    // Alters the valid property of the given relay
    function validateRelay(address _relayer, uint _relayIndex) public onlyRole(MINTER_ROLE) {
        // Check the relay is invalid before trying to validate it
        require(relays[_relayer][_relayIndex].valid == false);

        bool isValid = validate(
            msg.sender,
            _relayer,
            relays[_relayer][_relayIndex].merkleRoot,
            relays[_relayer][_relayIndex].leaf,  
            relays[_relayer][_relayIndex].metadata

        );
        if (isValid == true) {
            // Update state
            relays[_relayer][_relayIndex].valid = isValid;
            // Emit event
            emit RelayValidated(_relayer, _relayIndex);
        }
    }

    function validate(address creator,address _relayer,bytes32 _merkleRoot,bytes32 leaf,string memory metadata) internal pure returns(bool){
        return true;
    
    }

    // Submits proof of relay completion and mints reward
    function submitProof(address _tokenAddress,address _relayer, uint256 _relayIndex, bytes32[] memory _proof, bytes32 _leaf) public onlyRole(MINTER_ROLE){
        Relay memory relay = relays[_tokenAddress][_relayIndex];

        // Check relay is valid
        require(relay.valid == true);

        // Avoid the creator winning their own relay
        require(_relayer != relay.creator);

        require(MerkleProof.verify(_proof, relay.merkleRoot, _leaf));
        validrelay[_relayer].push(_relayIndex);

        // Emit event
        emit RelayCompleted(_relayer, _relayIndex, true);

        // Mint reward
        claimReward(_tokenAddress);
    }

    // Claims the relay reward, if not already claimed
    function claimReward(address _relayer) public onlyRole(MINTER_ROLE){
        // Check if relay is valid
        
        require(validrelay[_relayer].length>0);
        require(block.timestamp - lastClaim == 60 minutes);
        viper.mint(_relayer,reward*validrelay[_relayer].length);
        lastClaim= block.timestamp;
        emit RelayRewardClaimed(_relayer,"reward claimed");
        delete validrelay[_relayer];
        
    
    } 
   
    function withdrawBalance(address _relayer) public onlyOwner {
        uint balance = _relayer.balance;
        // Check if there's any balance to withdraw
        require(balance > 0);

        // Transfer balance
        (bool sent,)= _relayer.call{value: balance}("");
        sent= true;

        // Zero out the current owner balance
        balance = 0;

        // Emit event
        emit OwnerBalanceWithdrawn(_relayer, balance);
    }


    function getRelayerBalance(address _relayer) public view returns (uint) {
        return _relayer.balance;
    }


    function getrelay(address _relayer,uint256 _relayIndex) public view returns (address,
       bytes32,bytes32, string memory,bool ) {
        Relay memory relay = relays[_relayer][_relayIndex];

        return (relay.creator, relay.merkleRoot,relay.leaf,
            relay.metadata, relay.valid);
    }

    function getrelayCreator(address _relayer, uint _relayIndex) public view returns(address) {
        return relays[_relayer][_relayIndex].creator;
    }

    function getrelayMerkleRoot(address _relayer, uint _relayIndex) public view returns(bytes32) {
        return relays[_relayer][_relayIndex].merkleRoot;
    }

    function getrelayMerkleleaf(address _relayer, uint _relayIndex) public view returns(bytes32) {
        return relays[_relayer][_relayIndex].leaf;
    }


    function getrelayMetadata(address _relayer, uint _relayIndex) public view returns(string memory) {
        return relays[_relayer][_relayIndex].metadata;
    }

    function getrelayValid(address _relayer, uint _relayIndex) public view returns(bool) {
        return relays[_relayer][_relayIndex].valid;
    }

}
*/