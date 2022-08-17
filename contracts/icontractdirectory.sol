//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract IContractDirectory is Ownable {
    // State
    mapping (bytes32 => address) public contracts;

    /*
     *  Sets a contract address for the specified key
     *  bytes32 _name - Contract name
     *  address _address - Contract address
     */
    function setContract(bytes32 _name, address _address) public onlyOwner {}

    /*
     *  Get contract address for key
     *  bytes32 _name
     */
    function getContract(bytes32 _name) public returns(address) {}
}