//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./icontractdirectory.sol";

contract ContractDirectoryAPI is IContractDirectory {
    /*
     *  Sets a contract address for the specified key
     *  bytes32 _name - Contract name
     *  address _address - Contract address
     */
    function setContract(bytes32  _name, address _address) public virtual override onlyOwner {
        contracts[_name] = _address;
    }

    /*
     *  Get contract address for key
     *  bytes32 _name
     */
    function getContract(bytes32 _name) public virtual override returns(address) {
        return contracts[_name];
    }
}