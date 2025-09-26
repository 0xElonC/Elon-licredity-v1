// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import {IERC721} from "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";


/// @title NonFungible
/// @notice Represents a non-fungible
/// @dev 160 bits token address | 32 bits empty | 64 bits token ID
type NonFungible is bytes32;

using { equals as ==} for NonFungible global;
using NonFungibleLibrary for NonFungible global;

function equals(NonFungible self, NonFungible other) pure returns(bool _equal) {
    assembly ("memory-safe") {
        _equal := iszero(
            and(xor(self,other),0xffffffffffffffffffffffffffffffffffffffff00000000ffffffffffffffff)
        )
    }
}
/// @title NonFungibleLibrary
/// @author 
/// @notice Library for managing non-fungibles
library NonFungibleLibrary{
    /// 将 NonFungible 交易给 recipient
    /// @param self  The non-fungible to transfer
    /// @param recipient  The recipient of the transfer
    function transfer(NonFungible self,address recipient) internal {
        IERC721(self.tokenAddress()).safeTransferFrom(address(this),recipient,self.tokenId());
    }
    /// 获取token地址
    /// @param self The non-fungible
    function tokenAddress(NonFungible self) internal pure returns(address _tokenAddress){
        assembly ("memory-safe") {
            _tokenAddress := shr(96,self)
        }
    }
    /// 获取tokenId
    /// @param self  The non-fungible
    function tokenId(NonFungible self) internal pure returns(uint256 _tokenId){
        assembly ("memory-safe") {
            _tokenId := and(self,0xffffffffffffffff)
        }
    }
    /// 获取拥有者
    /// @param self The non-fungible
    function owner(NonFungible self) internal view returns(address _owner){
        _owner = IERC721(self.tokenAddress()).ownerOf(self.tokenId());
    }
}