// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {BUSD} from "../src/BUSD.sol";
import {CCNFT} from "../src/CCNFT.sol";

contract DeployBUSD is Script {
    function run() external returns (BUSD busd) {
        vm.startBroadcast();
        busd = new BUSD();
        vm.stopBroadcast();
        console.log("BUSD:", address(busd));
    }
}

contract DeployCCNFT is Script {
    function run() external returns (CCNFT ccnft) {
        vm.startBroadcast();
        ccnft = new CCNFT();
        vm.stopBroadcast();
        console.log("CCNFT:", address(ccnft));
    }
}
