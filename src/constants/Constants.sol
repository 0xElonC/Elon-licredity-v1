// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

    //Locker
    uint256 constant LOKER_ERROR_AlreadyUnlocked = 0x5090d6c6;
    uint256 constant LOKER_ERROR_AlreadyLocked = 0x5f0ccd7c;
    uint256 constant LOKER_ERRPR_POINT = 0x1c;
    uint256 constant LOKER_SELECT_SIZE = 0x04;
    uint256 constant LOKER_ZERO = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe;

    //Store
    uint256 constant OWNER_OFFSET = 0;
    uint256 constant DEPT_SHARE_OFFSET = 1;
    uint256 constant FUNGIBLE_OFFSET = 2;
    uint256 constant NON_FUNGIBLE_OFFSET = 3;
    uint256 constant FUNGIBLE_STATES_OFFSET = 4;

    //error 
    error ZeroAddress();

    error NativeTransferFailed();

    error ERC20TransferFaild();

    error Overflow();

