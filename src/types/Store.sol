// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {Fungible} from "./Fungible.sol";
import {FungibleState, toFungibleState} from "./FungibleState.sol";
import {NonFungible} from "./NonFungible.sol";

struct Store{
    address owner;//抵押方
    uint256 debtShare;//债务份额
    Fungible[] fungibles;//可替代代币数组
    nonFungible nonfungibles;//不可替代代币数组
    mapping(Fungible => FungibleStates) fungibleStates;//可替代代币映射状态
}