// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


type FungibleState is bytes32;

using FungibleStateLibrary for FungibleState global;

/// 转化为FungibleState，将index和balance存在一个内存中
/// @param index 索引
/// @param _balance 余额
/// [ 64 bits index | (空 64 bits) | 128 bits balance ]
function toFungibleState(uint256 index,uint256 _balance)pure returns(FungibleState _state){
    assembly ("memory-safe") {
        //requires(index <= 0xffffffffffffffff && _balance <= 0xffffffffffffffffffffffffffffffff)
        if or(gt(index,0xffffffffffffffff),gt(_balance,0xffffffffffffffffffffffffffffffff)){
            mstore(0x00,0x35278d12)//Overflow()
            revert(0x1c,0x04)
        }   
        _state := or(shl(192,index),_balance)
    }
}

library FungibleStateLibrary {
    /// 获取index索引
    /// @param self 同质化代币状态
    function index(FungibleState self) internal view returns(uint256 _index){
        assembly ("memory-safe") {
            _index := shr(192,self)
        }
    }
    /// 获取余额
    /// @param self 同质化代币状态
    function balance(FungibleState self) internal view returns(uint256 _balance){
        assembly ("memory-safe"){
            _balance := and(self,0xffffffffffffffffffffffffffffffff)
        }
    }
}