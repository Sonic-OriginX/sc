// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "src/OriginX.sol";
import "src/MockSonic.sol";
import "src/MockLBTC.sol";

contract OriginXTest is Test {
    OriginX originX;
    MockSonic tokenA;
    MockLBTC tokenB;
    address user;
    address owner;

    function setUp() public {
        owner = address(this);
        user = address(0x123);

        tokenA = new MockSonic();
        tokenB = new MockLBTC();
        
        originX = new OriginX(address(this));

        tokenA.mint(user, 1_000_000 * 10**6);
        tokenB.mint(user, 1_000_000 * 10**6);

        tokenB.mint(address(originX), 1_000_000 * 10**6);
        tokenA.mint(address(originX), 1_000_000 * 10**6);
    }

    function testDeposit() public {
        vm.prank(user);
        tokenA.approve(address(originX), 100 * 10**6);
        
        vm.prank(user);
        originX.deposit(address(tokenA), user, address(this), 50 * 10**6);
        assertEq(tokenA.balanceOf(address(this)), 50 * 10**6);
    }

    function testWithdraw() public {
        vm.prank(user);
        tokenA.approve(address(originX), 100 * 10**6);
        
        vm.prank(user);
        originX.deposit(address(tokenA), user, address(this), 50 * 10**6);

        tokenA.approve(address(originX), 50 * 10**6);
        
        vm.prank(address(this));
        originX.withdraw(address(tokenA), address(this), user, 50 * 10**6);
        assertEq(tokenA.balanceOf(user), 1_000_000 * 10**6);
    }

    function testSwap() public {
        tokenB.mint(address(originX), 1_000_000 * 10**6);

        uint256 initialTokenBBalance = tokenB.balanceOf(user);

        vm.prank(user);
        tokenA.approve(address(originX), 50 * 10**6);
        originX.swap(address(tokenA), address(tokenB), 50 * 10**6);

        uint256 finalTokenBBalance = tokenB.balanceOf(user);

        assertEq(finalTokenBBalance, initialTokenBBalance + 50 * 10**6);
    }

}