// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BUSD} from "../src/BUSD.sol";
import {CCNFT} from "../src/CCNFT.sol";

contract CCNFTTest is Test {
    address deployer;
    address c1;
    address c2;
    address funds;
    address fees;
    BUSD busd;
    CCNFT ccnft;

    function setUp() public {
        deployer = address(this);
        c1 = makeAddr("c1");
        c2 = makeAddr("c2");
        funds = makeAddr("funds");
        fees = makeAddr("fees");
        busd = new BUSD();
        ccnft = new CCNFT();
    }

    function testSetFundsCollector() public {
        ccnft.setFundsCollector(funds);
        assertEq(ccnft.fundsCollector(), funds);
    }

    function testSetFeesCollector() public {
        ccnft.setFeesCollector(fees);
        assertEq(ccnft.feesCollector(), fees);
    }

    function testSetProfitToPay() public {
        ccnft.setProfitToPay(500);
        assertEq(ccnft.profitToPay(), 500);
    }

    function testSetCanBuy() public {
        ccnft.setCanBuy(true);
        assertTrue(ccnft.canBuy());
        ccnft.setCanBuy(false);
        assertFalse(ccnft.canBuy());
    }

    function testSetCanTrade() public {
        ccnft.setCanTrade(true);
        assertTrue(ccnft.canTrade());
        ccnft.setCanTrade(false);
        assertFalse(ccnft.canTrade());
    }

    function testSetCanClaim() public {
        ccnft.setCanClaim(true);
        assertTrue(ccnft.canClaim());
        ccnft.setCanClaim(false);
        assertFalse(ccnft.canClaim());
    }

    function testSetMaxValueToRaise() public {
        ccnft.setMaxValueToRaise(1000 ether);
        assertEq(ccnft.maxValueToRaise(), 1000 ether);
        ccnft.setMaxValueToRaise(5000 ether);
        assertEq(ccnft.maxValueToRaise(), 5000 ether);
    }

    function testAddValidValues() public {
        ccnft.addValidValues(100 ether);
        ccnft.addValidValues(200 ether);
        assertTrue(ccnft.validValues(100 ether));
        assertTrue(ccnft.validValues(200 ether));
        assertFalse(ccnft.validValues(300 ether));
    }

    function testSetMaxBatchCount() public {
        ccnft.setMaxBatchCount(10);
        assertEq(ccnft.maxBatchCount(), 10);
    }

    function testSetBuyFee() public {
        ccnft.setBuyFee(100);
        assertEq(ccnft.buyFee(), 100);
    }

    function testSetTradeFee() public {
        ccnft.setTradeFee(200);
        assertEq(ccnft.tradeFee(), 200);
    }

    function testCannotTradeWhenCanTradeIsFalse() public {
        ccnft.setCanTrade(false);
        vm.expectRevert("Trade disabled");
        ccnft.trade(1);
    }

    function testCannotTradeWhenTokenDoesNotExist() public {
        ccnft.setCanTrade(true);
        vm.expectRevert("Token does not exist");
        ccnft.trade(999);
    }

    // --- Flujo completo (extra) ---

    function _setupBuy() internal {
        ccnft.setFundsToken(address(busd));
        ccnft.setFundsCollector(funds);
        ccnft.setFeesCollector(fees);
        ccnft.setCanBuy(true);
        ccnft.setCanClaim(true);
        ccnft.setCanTrade(true);
        ccnft.setMaxBatchCount(10);
        ccnft.setMaxValueToRaise(10000 ether);
        ccnft.setBuyFee(100); // 1%
        ccnft.setTradeFee(100); // 1%
        ccnft.setProfitToPay(1000); // 10%
        ccnft.addValidValues(100 ether);
        busd.transfer(c1, 1000 ether);
        busd.transfer(c2, 1000 ether);
        vm.prank(c1);
        busd.approve(address(ccnft), type(uint256).max);
        vm.prank(c2);
        busd.approve(address(ccnft), type(uint256).max);
    }

    function testBuy() public {
        _setupBuy();
        vm.prank(c1);
        ccnft.buy(100 ether, 2);
        assertEq(ccnft.balanceOf(c1), 2);
        assertEq(ccnft.ownerOf(0), c1);
        assertEq(ccnft.totalValue(), 200 ether);
        assertEq(busd.balanceOf(funds), 200 ether);
        assertEq(busd.balanceOf(fees), 2 ether);
    }

    function testCannotBuyInvalidValue() public {
        _setupBuy();
        vm.prank(c1);
        vm.expectRevert("Invalid value");
        ccnft.buy(50 ether, 1);
    }

    function testTradeFlow() public {
        _setupBuy();
        vm.prank(c1);
        ccnft.buy(100 ether, 1);
        vm.prank(c1);
        ccnft.putOnSale(0, 150 ether);
        assertEq(ccnft.listTokensOnSale(0), 0);
        vm.prank(c2);
        ccnft.trade(0);
        assertEq(ccnft.ownerOf(0), c2);
        assertEq(busd.balanceOf(c1), 900 ether - 1 ether + 150 ether);
        vm.expectRevert();
        ccnft.listTokensOnSale(0);
    }

    function testClaim() public {
        _setupBuy();
        vm.prank(c1);
        ccnft.buy(100 ether, 1);
        // fundsCollector debe aprobar al contrato para pagar el claim
        busd.transfer(funds, 100 ether);
        vm.prank(funds);
        busd.approve(address(ccnft), type(uint256).max);
        uint256[] memory ids = new uint256[](1);
        ids[0] = 0;
        vm.prank(c1);
        ccnft.claim(ids);
        assertEq(ccnft.balanceOf(c1), 0);
        assertEq(ccnft.totalValue(), 0);
        // c1: 1000 - 100 - 1 (fee) + 110 (valor + 10%)
        assertEq(busd.balanceOf(c1), 1000 ether - 100 ether - 1 ether + 110 ether);
    }

    function testDirectTransferNotAllowed() public {
        _setupBuy();
        vm.prank(c1);
        ccnft.buy(100 ether, 1);
        vm.prank(c1);
        vm.expectRevert("Not Allowed");
        ccnft.transferFrom(c1, c2, 0);
    }
}
