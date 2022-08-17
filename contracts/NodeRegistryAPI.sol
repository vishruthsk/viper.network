//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./BaseAPI.sol";
import "./NodeRegistry.sol";
import "./ViperGeyser.sol";


contract NodeRegistryAPI is  NodeRegistry {
    ViperGeyser token;
    // Events
    event NodeRegistered(address _owner, bytes32 _nonce, bytes8[] _networks, string _endpoint);

    // Functions
    /*
     *  allows to register a new Node, returning a bytes32 nonce for the Node, if it doesn't exist already, in which case it will error out.
     *  bytes8[] _networks - List of networks this Node supports (BTC, ETH, etc.).
     *  string _endpoint - The endpoint information in multi addr format.
     */
    function register(bytes8[] memory _networks, string memory _endpoint) public virtual override returns(bytes32) {
        require(token.totalStakedFor(msg.sender) > 10000);
        bytes32 nodeNonce = keccak256(abi.encodePacked(_networks, _endpoint, msg.sender, nodesPerAccount[msg.sender].length));
        nodes[nodeNonce] = Models.Node(nodeNonce, msg.sender, _networks, _endpoint);
        nodesIndex.push(nodeNonce);
        nodesPerAccount[msg.sender].push(nodeNonce);
        otherNodes();
        emit NodeRegistered(msg.sender, nodeNonce, _networks, _endpoint);
        return nodeNonce;
    }

    /*
     *  Verify existence of a given Node nonce
     *  bytes32 _nodeNonce - Nonce to verify against.
     */
    function isNode(bytes32 _nodeNonce) public view virtual override returns(bool) {
        return nodes[_nodeNonce].nonce != bytes32(0);
    }

    /*
     *  Verify ownership of a given Node.
     *  address _possibleOwner - The possible owner of the given node we want to verify
     *  bytes32 _nodeNonce - The nonce of the Node we want to verify
     */
    function isOwner(address _possibleOwner, bytes32 _nodeNonce) public view virtual override returns(bool) {
        return nodes[_nodeNonce].owner == _possibleOwner;
    }

    /*
     *  Returns the owner of the node
     *  bytes32 _nodeNonce
     */
    function getNodeOwner(bytes32 _nodeNonce) public view virtual override returns(address) {
        return nodes[_nodeNonce].owner;
    }

    /*
     *  Returns a paginated list of the nodes owned by the account
     *  address _owner - address of owner
     *  uint256 _page - page number
     */
    function getOwnerNodes(address _owner, uint256 _page) public view virtual override returns (bytes32[] memory) {
        uint256 totalNodes = uint256(nodesPerAccount[_owner].length);
        bytes32[] memory result = new bytes32[](10);
        if(totalNodes > 0 && _page > 0){
            uint256 initialIndex = SafeMath.mul(uint256(SafeMath.sub(_page, 1)), 10);
            uint256 lastIndex = SafeMath.add(initialIndex, 10);
            if(initialIndex < totalNodes) {
                uint256 resultIndex = 0;
                for(uint256 i = initialIndex; i < lastIndex; i++){
                    if(i < totalNodes){
                        result[resultIndex] = bytes32(nodesPerAccount[_owner][i]);
                    } else {
                        result[resultIndex] = bytes32(0);
                    }
                    resultIndex = SafeMath.add(resultIndex, 1);
                }
            }
        }
        return result;
    }

    /*
     *  Returns the Node information given the nonce
     *  bytes32 _nodeNonce
     */
    function getNode(bytes32 _nodeNonce) public view virtual override returns (bytes32, address, bytes8[] memory, string memory) {
        return(nodes[_nodeNonce].nonce, nodes[_nodeNonce].owner, nodes[_nodeNonce].networks, nodes[_nodeNonce].endpoint);
    }

    /*
     *  Returns the length of the nodesIndex array
     */
    function getNodesIndexLength() public view virtual override returns (uint256) {
        return nodesIndex.length;
    }
    /*
     * Returns the nodes list  
     */
    function otherNodes() public returns(bytes32){
        return nodesIndex;
    }
}