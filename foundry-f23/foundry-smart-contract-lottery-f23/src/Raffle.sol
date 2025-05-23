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
    error Rafle__NotEnoughEthSent();
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval; // duration of the lottery in seconds
    address payable[] private s_players; //array of addresses -> list of players
    uint256 private s_lastTimeStamp;

    event EnteredRaffle(address indexed player);

    constructor(uint256 entranceFee, uint256 interval) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function enterRaffle() external payable {
        //require(msg.value >= i_entranceFee, "Not enough ETH");
        if (msg.value < i_entranceFee) {
            revert Rafle__NotEnoughEthSent();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() external {
        if (block.timestamp - s_lastTimeStamp <= i_interval) {
            revert();
        }
        // get a random winner with chainlink vrf
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
