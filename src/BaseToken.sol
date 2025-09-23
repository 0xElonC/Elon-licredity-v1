// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

abstract contract BaseERC20 is IERC20 {
    struct OwnerData {
        uint256 balance;
        mapping(address => uint256) allowances;
    }

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => OwnerData) internal ownerData;
    //error event
    error TransferToZeroAddress();
    error InsufficientAllowance();

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        require(spender != address(0), "spender address is null");
        OwnerData storage o = ownerData[msg.sender];
        o.allowances[spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveAssembly(
        address spender,
        uint256 amount
    ) public returns (bool) {
        assembly ("memory-safe") {
            spender := and(spender, 0xffffffffffffffffffffffffffffffffffffffff)

            //计算所有者数据槽
            mstore(0x00, caller())
            mstore(0x20, ownerData.slot)
            let ownerDataSlot := keccak256(0x00, 0x40)
            // set amount
            mstore(0x00, spender)
            mstore(0x20, add(ownerDataSlot, 1))
            sstore(keccak256(0x00, 0x40), amount)
            // emit EVENT
            mstore(0x00, amount)
            log3(
                0x00,
                0x20,
                0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925,
                caller(),
                spender
            )
        }
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        require(to != address(0), "to is address(0)");
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(to != address(0), "transfer to zero address");
        // optional: enforce allowance if desired (not strictly required for gas tests here)
        // require(ownerData[from].allowances[msg.sender] >= amount, "insufficient allowance");
        ownerData[from].balance -= amount;
        ownerData[to].balance += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function transferFormAssembly(
        address from,
        address to,
        uint256 amount
    ) public returns (bool){
        assembly ("memory-safe") {
            from := and(from,0xffffffffffffffffffffffffffffffffffffffff)

            if iszero(to) {
                mstore(0x00,0xea553b34)//TransferToZeroAddress()
                revert(0x1c,0x04)
            }
            if iszero(from){
                mstore(0x00,0xea553b34)
                revert(0x1c,0x04)
            }

            if iszero(eq(from,caller())){
                mstore(0x00,from)
                mstore(0x00,ownerData.slot)
                let ownerDataSlot := keccak256(0x00,0x40)
                
                //get allowence
                mstore(0x00,caller())
                mstore(0x20,add(ownerDataSlot,1))
                let allowanceSlot := keccak256(0x00,0x40)
                let _allowance := sload(allowanceSlot)

                //require(_allowance >= amount)
                if lt(_allowance,amount){
                    mstore(0x00,0x13be252b)
                    revert(0x1c,0x04)
                }

                //update allowance
                if iszero(sload(_allowance)){
                    sstore(allowanceSlot,sub(_allowance , amount))
                }
            }
        }
        _transferAssembly(from, to, amount);
        return true;
    }

    function _mint(address to, uint256 amount) internal {
        _transferAssembly(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        _transferAssembly(from, address(0), amount);
    }

    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0)) {
            //mint
            totalSupply += amount;
        } else {
            //transfer
            ownerData[from].balance -= amount;
        }
        if (to == address(0)) {
            //born
            totalSupply -= amount;
        } else {
            ownerData[to].balance += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _transferAssembly(
        address from,
        address to,
        uint256 amount
    ) public {
        if (from == address(0)) {
            //mint
            totalSupply += amount;
        } else {
            //transfer
            ownerData[from].balance -= amount;
        }
        assembly ("memory-safe") {
            from := and(from, 0xffffffffffffffffffffffffffffffffffffffff)
            to := and(to, 0xffffffffffffffffffffffffffffffffffffffff)

            //burn
            if iszero(to) {
                sstore(totalSupply.slot, sub(sload(totalSupply.slot), amount))
            }

            //transfer
            if iszero(iszero(to)) {
                mstore(0x00, to)
                mstore(0x20, ownerData.slot)
                let balanceSlot := add(keccak256(0x00, 0x40), 0)
                sstore(balanceSlot, add(sload(balanceSlot), amount))
            }
            mstore(0x00, amount)
            log3(
                0x00,
                0x20,
                0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef,
                from,
                to
            )
        }
    }
}
