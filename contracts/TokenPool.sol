//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./VIPER.sol";

/**
 * This is a simple contract to hold tokens.
 */
contract TokenPool is Ownable {
    VIPER viper;
 
    constructor() public {
    
    }

    function balance() public view returns (uint256) {
        return viper.balanceOf(address(this));
    }

    function transfer(address to, uint256 value) external onlyOwner returns (bool) {
        return viper.transfer(to, value);
    }

}