//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract IStaking {
    
    function stake(uint256 amount, bytes calldata data) external{}
    function stakeFor(address user, uint256 amount, bytes calldata data) external{}
    function unstake(uint256 amount, bytes calldata data) external{}
    function totalStakedFor(address addr) public view returns (uint256){}
    function totalStaked() public view returns (uint256){}
    function token() external view returns (address){}

}