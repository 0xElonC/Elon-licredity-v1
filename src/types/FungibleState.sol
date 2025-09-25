// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

type FungibleState is bytes32;

using FungibleStateLibrary for FungibleState global;

/// 转化为FungibleState，将index和balance存在一个内存中
/// @param index 
/// @param _balance 
function toFungibleState(uint256 index,uint256 _balance) returns(FungibleState _state){
    assembly ("memory-safe") {
        //requires(index <= 0xffffffffffffffff && _balance <= 0xffffffffffffffffffffffffffffffff)
        if or(gt(index,0xffffffffffffffff),gt(_balance,0xffffffffffffffffffffffffffffffff)){
            mstore(0x00,0x35278d12)//Overflow()
            revert(0x1c,0x04)
        }   
        state := or(shl(192,index),_balance);
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