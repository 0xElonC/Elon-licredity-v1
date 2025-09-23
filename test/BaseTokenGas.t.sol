// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "lib/forge-std/src/Test.sol";
import "../src/TestToken.sol";

contract BaseTokenGasTest is Test {
    TestToken public token;
    address public user1;
    address public user2;
    uint256 public approveAmount = 1000 * 10**18;
    uint256 public transferAmount = 100 * 10**18;

    function setUp() public {
        token = new TestToken();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // 给 user1 一些代币用于测试
        vm.prank(address(this));
        token.transfer(user1, 10000 * 10**18);
    }

    function testApproveGas() public {
        vm.prank(user1);
        
        // 测量 approve 方法的 gas 消耗
        uint256 gasBefore = gasleft();
        token.approve(user2, approveAmount);
        uint256 gasAfter = gasleft();
        uint256 gasUsedApprove = gasBefore - gasAfter;
        
        console.log("approve() gas used:", gasUsedApprove);
        
        // 验证 approve 是否成功
        assertEq(token.allowance(user1, user2), approveAmount);
    }

    function testApproveAssemblyGas() public {
        vm.prank(user1);
        
        // 测量 approveAssembly 方法的 gas 消耗
        uint256 gasBefore = gasleft();
        token.approveAssembly(user2, approveAmount);
        uint256 gasAfter = gasleft();
        uint256 gasUsedApproveAssembly = gasBefore - gasAfter;
        
        console.log("approveAssembly() gas used:", gasUsedApproveAssembly);
        
        // 验证 approveAssembly 是否成功
        assertEq(token.allowance(user1, user2), approveAmount);
    }

    function testGasComparison() public {
        // 重置状态
        vm.prank(user1);
        token.approve(user2, 0);
        
        // 测试 approve
        vm.prank(user1);
        uint256 gasBefore1 = gasleft();
        token.approve(user2, approveAmount);
        uint256 gasAfter1 = gasleft();
        uint256 gasUsedApprove = gasBefore1 - gasAfter1;
        
        // 重置状态
        vm.prank(user1);
        token.approve(user2, 0);
        
        // 测试 approveAssembly
        vm.prank(user1);
        uint256 gasBefore2 = gasleft();
        token.approveAssembly(user2, approveAmount);
        uint256 gasAfter2 = gasleft();
        uint256 gasUsedApproveAssembly = gasBefore2 - gasAfter2;
        
        console.log("=== Gas Comparison ===");
        console.log("approve() gas used:", gasUsedApprove);
        console.log("approveAssembly() gas used:", gasUsedApproveAssembly);
        
        if (gasUsedApprove > gasUsedApproveAssembly) {
            uint256 gasSaved = gasUsedApprove - gasUsedApproveAssembly;
            console.log("Gas saved by assembly:", gasSaved);
            console.log("Gas reduction percentage:", (gasSaved * 100) / gasUsedApprove);
        } else {
            uint256 gasExtra = gasUsedApproveAssembly - gasUsedApprove;
            console.log("Extra gas used by assembly:", gasExtra);
        }
        
        // 验证两个方法的结果一致
        assertEq(token.allowance(user1, user2), approveAmount);
    }

    function testMultipleApprovesGas() public {
        address[] memory spenders = new address[](5);
        for (uint i = 0; i < 5; i++) {
            spenders[i] = makeAddr(string(abi.encodePacked("spender", i)));
        }
        
        // 测试多次 approve 的 gas 消耗
        vm.startPrank(user1);
        
        uint256 totalGasApprove = 0;
        for (uint i = 0; i < spenders.length; i++) {
            uint256 gasBefore = gasleft();
            token.approve(spenders[i], approveAmount);
            uint256 gasAfter = gasleft();
            totalGasApprove += (gasBefore - gasAfter);
        }
        
        // 重置 allowances
        for (uint i = 0; i < spenders.length; i++) {
            token.approve(spenders[i], 0);
        }
        
        uint256 totalGasApproveAssembly = 0;
        for (uint i = 0; i < spenders.length; i++) {
            uint256 gasBefore = gasleft();
            token.approveAssembly(spenders[i], approveAmount);
            uint256 gasAfter = gasleft();
            totalGasApproveAssembly += (gasBefore - gasAfter);
        }
        
        vm.stopPrank();
        
        console.log("=== Multiple Approves Gas Comparison ===");
        console.log("Total approve() gas:", totalGasApprove);
        console.log("Total approveAssembly() gas:", totalGasApproveAssembly);
        console.log("Average approve() gas:", totalGasApprove / spenders.length);
        console.log("Average approveAssembly() gas:", totalGasApproveAssembly / spenders.length);
        
        if (totalGasApprove > totalGasApproveAssembly) {
            uint256 totalGasSaved = totalGasApprove - totalGasApproveAssembly;
            console.log("Total gas saved:", totalGasSaved);
            console.log("Average gas saved per call:", totalGasSaved / spenders.length);
        }
    }

    function testGasWithDifferentAmounts() public {
        uint256[] memory amounts = new uint256[](4);
        amounts[0] = 1;
        amounts[1] = 1000;
        amounts[2] = 1000000;
        amounts[3] = type(uint256).max;
        
        console.log("=== Gas Usage for Different Amounts ===");
        
        for (uint i = 0; i < amounts.length; i++) {
            // 重置状态
            vm.prank(user1);
            token.approve(user2, 0);
            
            // 测试 approve
            vm.prank(user1);
            uint256 gasBefore1 = gasleft();
            token.approve(user2, amounts[i]);
            uint256 gasAfter1 = gasleft();
            uint256 gasUsedApprove = gasBefore1 - gasAfter1;
            
            // 重置状态
            vm.prank(user1);
            token.approve(user2, 0);
            
            // 测试 approveAssembly
            vm.prank(user1);
            uint256 gasBefore2 = gasleft();
            token.approveAssembly(user2, amounts[i]);
            uint256 gasAfter2 = gasleft();
            uint256 gasUsedApproveAssembly = gasBefore2 - gasAfter2;
            
            console.log("Amount:", amounts[i]);
            console.log("  approve() gas:", gasUsedApprove);
            console.log("  approveAssembly() gas:", gasUsedApproveAssembly);
            if (gasUsedApprove > gasUsedApproveAssembly) {
                console.log("  Gas saved:", gasUsedApprove - gasUsedApproveAssembly);
            }
        }
    }


    //测试转账
    function testTransferGas() public {
        vm.prank(user1);
        //测量 transfer 方法的 gas 消耗
        uint256 gasBefore = gasleft();
        token.transfer(user2, transferAmount);
        uint256 gasAfter = gasleft();
        uint256 gasUsedTransfer = gasBefore - gasAfter;
        console.log("transfer() gas used",gasUsedTransfer);

        //验证转账是否成功
        assertEq(token.balanceOf(user2),transferAmount);
    }

    function testTransferAssemblyGas() public {
        vm.prank(user1);

        uint256 gasBefore = gasleft();
        token._transferAssembly(user1,user2, transferAmount);
        uint256 gasAfter = gasleft();
        uint256 gasUsedTransfer = gasBefore - gasAfter;
        console.log("testTransferGas() gas used",gasUsedTransfer);

        assertEq(token.balanceOf(user2),transferAmount);
    }

    function testTransferFromAssemblyGas() public {
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        token.transferFormAssembly(user1,user2, transferAmount);
        uint256 gasAfter = gasleft();
        uint256 gasUsedTransfer = gasBefore - gasAfter;
        console.log("testTransferFromAssemblyGas() gas used",gasUsedTransfer);
        assertEq(token.balanceOf(user2),transferAmount);
    }
}