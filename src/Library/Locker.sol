// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;
import "../constants/Constants.sol";
library Locker {
    //bytes32(uint256(keccak256(abi.encode(input)))+1) [32位计数器][223位空位][1位解锁标志]
    bytes32 private constant LOCKER_SLOT = 0xa923a97161fea2be6ba987c81c443b65e5dd8a139a46e87582b6df9b5c5a07fb;

    /**
     * 创建仓位的操作只可以在unlock下执行
     */
    function unlock() internal{
        assembly ("memory-safe"){
            let locker := tload(LOCKER_SLOT)
            //判断locker状态是否为解锁 1-解锁 0-未解锁
            if iszero(iszero(and(locker,0x01))){
                mstore(0x00,LOKER_ERROR_AlreadyUnlocked)
                revert(LOKER_ERRPR_POINT,LOKER_SELECT_SIZE)//solidty内存前64字节通常用于存储临时数据
            }

            let count := shr(224,locker)
            mstore(0x20,LOCKER_SLOT)
            //清理 Transient Storage
            for {let i:= 1} iszero(gt(i,count)) {i := add(i,1)}{
                let itemSlot := add(LOCKER_SLOT,mul(0x20,i))
                mstore(0x00,tload(itemSlot))

                tstore(keccak256(0x00,0x40),false)
                tstore(itemSlot,0)
            }
            //解锁
            tstore(LOCKER_SLOT,0x01)
        }
    }
    /**
     * 锁住，无法开仓
     */
    function lock() internal{
        assembly ("memory-safe") {
            let locker := tload(LOCKER_SLOT)
            //判断是不是已解锁状态，不是的话直接回滚
            if iszero(and(locker,0x01)){
                mstore(0x00,LOKER_ERROR_AlreadyLocked)
                revert(LOKER_ERRPR_POINT,0x04)
            }

            tstore(LOCKER_SLOT,and(locker,LOKER_ZERO))
        }
    }
}