// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "./types/Store.sol";
contract  Licredity {

    uint256 internal storeIdCount; //仓位数量
    mapping(uint256 => Store) internal stores;
    constructor() {
        
    }

    modifier noZeroAddress(address _address){
        _noZeroAddress(_address);
        _;
    }

    function _noZeroAddress(address _address) internal pure{
        assembly ("memory-safe") {
            if iszero(_address){
                mstore(0x00,0xd92e233d)//ZeroAddress()
                revert(0x1c,0x04)
            }
        }
    }

    function open() external returns(uint256 storeId){
        storeId = ++ storeIdCount;

    }
}