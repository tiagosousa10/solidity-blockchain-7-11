// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title A sample Raffle Contract
 * @author Tiago
 * @notice This is for creating a sample raffle
 * @dev Implements Chainlink VRFv2
 */
contract Raffle {
    error NotEnoughEthSent();
    uint256 private immutable i_entranceFee;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function enterRaffle() external payable {
        //require(msg.value >= i_entranceFee, "Not enough ETH");
        if (msg.value < i_entranceFee) {
            revert NotEnoughEthSent();
        }
    }

    function pickWinner() public {
        // use Chainlink VRFv2
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
