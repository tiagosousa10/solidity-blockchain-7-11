// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43); // Deploys the FundMe contract
        vm.stopBroadcast();
        return fundMe;
    }
}
