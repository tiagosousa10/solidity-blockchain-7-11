// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract RaffleTest is Test {
    //events
    event EnteredRaffle(address indexed player); // create event to listen to enterRaffle

    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link; // Only for Sepolia, not used in Anvil

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run(); // Deploy the Raffle contract
        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link // Only for Sepolia, not used in Anvil
        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_USER_BALANCE); // cheat code to give the player some ETH
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        //arrange
        vm.prank(PLAYER); // simulate a player
        //act / assert
        vm.expectRevert(Raffle.Rafle__NotEnoughEthSent.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        address playerRecorded = raffle.getPlayer(0); // get the first player
        assert(playerRecorded == PLAYER);
    }

    function testEmitsEventOnEntrance() public {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER); // emit the event
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCantEnterWhenRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle__RaffleIsNotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }

    function testCheckUpkeepReturnsFalseIfIthasNoBalance() public {
        vm.warp(block.timestamp + interval + 1); // move time forward
        vm.roll(block.number + 1); // move to the next block

        //act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        //assert
        assert(!upkeepNeeded); // upkeep should not be needed
    }

    function testCheckUpkeepReturnsFalseIfRaffleNotOpen() public {
        //arrange
        vm.prank(PLAYER); // simulate a player
        raffle.enterRaffle{value: entranceFee}(); // player enters the raffle
        vm.warp(block.timestamp + interval + 1); // move time forward
        vm.roll(block.number + 1); // move to the next block
        raffle.performUpkeep(""); // perform upkeep to change the state to calculating

        //act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");
        //assert
        assert(upkeepNeeded == false); // upkeep should not be needed
    }

    //testCheckUpkeepReturnsFalseIfEnoughTimeHasntPassed

    function testPerformUpkeepCanOnlyRunOfCheckUpkeepIsTrue() public {
        // arrange -> we need to enter the raffle
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}(); // player enters the raffle
        vm.warp(block.timestamp + interval + 1); // move time forward
        vm.roll(block.number + 1); // move to the next block

        //act -> we need to call performUpkeep
        raffle.performUpkeep(""); // perform upkeep to change the state to calculating
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        // arrange -> we need to enter the raffle
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        uint256 raffleState = 0; // 0 is OPEN state

        //act / assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                raffleState
            )
        ); // expect the revert

        raffle.performUpkeep(""); // perform upkeep to change the state to calculating
    }

    modifier raffleEnteredAndTimePassed() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}(); // player enters the raffle
        vm.warp(block.timestamp + interval + 1); // move time forward
        vm.roll(block.number + 1); // move to the next block
        _; // continue with the rest of the test
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId()
        public
        raffleEnteredAndTimePassed
    {
        //act
        vm.recordLogs(); // save the logs
        raffle.performUpkeep(""); // perform upkeep to change the state to calculating -> emit a requestId
        Vm.Log[] memory entries = vm.getRecordedLogs(); // get the logs
        bytes32 requestId = entries[1].topics[0]; // get the requestId from the logs

        Raffle.RaffleState rState = raffle.getRaffleState(); // get the raffle state

        assert(uint256(requestId) > 0); // requestId should be greater than 0
    }
}
