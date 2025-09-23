// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseToken.sol";

contract TestToken is BaseERC20 {
    constructor() BaseERC20("Test Token", "TST", 18) {
        totalSupply = 1000000 * 10**18;
        ownerData[msg.sender].balance = totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return ownerData[account].balance;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return ownerData[owner].allowances[spender];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "transfer to zero address");
        require(ownerData[msg.sender].balance >= amount, "insufficient balance");
        
        ownerData[msg.sender].balance -= amount;
        ownerData[to].balance += amount;
        
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}