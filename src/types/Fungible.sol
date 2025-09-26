// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ChainInfo} from "../Library/ChainInfo.sol";

type Fungible is address;

using {equals as ==} for Fungible global;
using FungibleLibrary for Fungible global;

function equals(Fungible self,Fungible other) pure returns(bool){
    return Fungible.unwrap(self) == Fungible.unwrap(other);
}

library FungibleLibrary{
    ///判断原生代币或ERC20代币，获取余额
    /// @param self 同质化代币地址
    /// @param owner 持有者
    function balanceof(Fungible self,address owner) internal view returns(uint256 _balance){
        _balance = self.isNative() ? owner.balance : IERC20(Fungible.unwrap(self)).balanceOf(owner);
    }
    /// 判断是否原生
    /// @param self 传入Fungible 地址
    function isNative(Fungible self) internal view returns(bool _isNative){
        _isNative = Fungible.unwrap(self) == ChainInfo.NATIVE;
    }

    function decimals(Fungible self) internal view returns(uint8 _decimals){
        _decimals = self.isNative() ? ChainInfo.NATIVE_DECIMALS : IERC20Metadata(Fungible.unwrap(self)).decimals();
    }
    function transfer(Fungible self,address recipient,uint256 amount) internal {
        if(self.isNative()){
            //native transfer
            assembly ("memory-safe") {
                let success := call(gas(),recipient,amount,0,0,0,0)
                if iszero(success){
                    mstore(0x00,0xf4b3b1bc)//NativeTransferFailed()
                    revert(0x1c,0x04)
                }
            }
        }else{
            //ERC20 transfer
            // bool success = IERC20(self).transfer(recipient,amount);
            // if(!success){
            //     revert ERC20TransferFaild();
            // }
            assembly ("memory-safe") {
                let fmp := mload(0x40)
                mstore(fmp,0xa9059cbb00000000000000000000000000000000000000000000000000000000)//transfer()
                mstore(add(fmp,0x04),and(recipient,0xffffffffffffffffffffffffffffffffffffffff))
                mstore(add(fmp,0x24),amount)
                
                let success := call(gas(),self,0,fmp,64,0,32)
                if success{
                    switch returndatasize()
                    //无返回值
                    case 0 {
                        success := 1
                    }
                    case 32 {
                        //returndatacopy(0x00,0x00,32)
                        success := eq(mload(0x00),1)
                    }
                    default {
                        success := 0
                    }
                }
                if iszero(success){
                    mstore(0x00,0x53dfbf77)//ERC20TransferFaild()
                    revert(0x1c,0x04)
                }
            }
        }
        
    }
}