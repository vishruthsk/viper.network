//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseAPI is Ownable {
    // State
    address public contractDirectory;

    // Functions
    /*
     *  Sets contract directory
     *  address _contractDirectory;
     */
    function setContractDirectory(address _contractDirectory) public onlyOwner {
        contractDirectory = _contractDirectory;
    }

    /*
     * Gets the contract directory
     */
    function getContractDirectory() public returns(address) {
        return contractDirectory;
    }
}