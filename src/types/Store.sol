// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Fungible} from "./Fungible.sol";
import {FungibleState, toFungibleState} from "./FungibleState.sol";
import {NonFungible} from "./NonFungible.sol";
import "../constants/Constants.sol";

struct Store {
    address owner; //抵押方
    uint256 debtShare; //债务份额
    Fungible[] fungibles; //可替代代币数组
    NonFungible nonfungibles; //不可替代代币数组
    mapping(Fungible => FungibleState) fungibleStates; //可替代代币映射状态
}

using StoreLibrary for Store global;

library StoreLibrary {
    /// 记录开仓者
    /// @param self The Store to set owner of
    /// @param owner 抵押者
    function setOwner(Store storage self, address owner) internal {
        assembly ("memory-safe") {
            //self.owner = owner;
            sstore(
                add(self.slot, OWNER_OFFSET),
                and(owner, 0xffffffffffffffffffffffffffffffffffffffff)
            )
        }
    }

    function addFungible(
        Store storage self,
        Fungible fungible,
        uint256 amount
    ) internal {
        FungibleState state = self.fungibleStates[fungible];

        //第一次抵押fungible
        if (state.index() == 0 && amount > 0) {
            assembly ("memory-safe") {
                let slot := add(self.slot, FUNGIBLE_OFFSET)
                let len := sload(slot)

                mstore(0x00, slot)
                sstore(add(keccak256(0x00, 0x20), len), fungible)
                sstore(slot, add(len, 1))
            }
        } else {
            state = toFungibleState(state.index(), state.balance() + amount);
        }
        //update fungible state
        assembly ("memory-safe") {
            mstore(0x00, fungible)
            mstore(0x20, add(self.slot, FUNGIBLE_STATES_OFFSET))
            sstore(keccak256(0x20, 0x40), state)
        }
    }

    function removeFungible(
        Store storage self,
        Fungible fungible,
        uint256 amount
    ) internal returns (bool) {
        FungibleState state = self.fungibleStates[fungible];
        uint256 index = state.index();
        uint256 newbalance = state.balance() - amount;
        if (index != 0) {
            if (newbalance != 0) {
                state = toFungibleState(index, newbalance);
            } else {
                state = FungibleState.wrap(0);
                assembly ("memory-safe") {
                    let slot := add(self.slot, FUNGIBLE_OFFSET)
                    let len := sload(slot)

                    mstore(0x00, slot)
                    let dataSlot := keccak256(0x00, 0x20)
                    if iszero(eq(index, len)) {
                        let lastFungible := sload(add(dataSlot, sub(len, 1)))
                        sstore(add(dataSlot, sub(index, 1)), lastFungible)

                        //update state
                        mstore(0x00, lastFungible)
                        mstore(0x20, add(self.slot, FUNGIBLE_STATES_OFFSET))
                        let stateSlot := keccak256(0x00, 0x40)
                        sstore(
                            stateSlot,
                            or(
                                shl(192, index),
                                and(
                                    sload(stateSlot),
                                    0xffffffffffffffffffffffffffffffff
                                )
                            )
                        )
                    }
                    //删除 fungible[]末位
                    sstore(add(dataSlot, sub(len, 1)), 0)
                    sstore(slot, sub(len, 1))
                }
            }

            //删除state末位
            assembly ("memory-safe") {
                mstore(0x00,fungible)
                mstore(0x20,self.slot)
                sstore(keccak256(0x00,0x40),state)
            }
        }
    }
}
