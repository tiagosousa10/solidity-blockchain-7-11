// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// AI
//1. Limit self-triage to 15/20minutes
//2. Don't be afraid to ask AI, but dont skip learning
//3. Use forums
//4. Google the exact error
//5. Post in stack exchange or peeranha.io
//6. Posting an issue on github/git

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded)
        public addressToAmountFunded;

    address public immutable i_owner;

    constructor() payable {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "didn't send enough ether"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // for loop
        // [1,2,3]
        //for(/*starting index, ending index, step amount */)
        //0, 10,1
        //0,1,2,3,4

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        //reset array
        funders = new address[](0);
        //withdraw the funds

        //msg.sender = address
        //payable(msg.sender) =  payable address
        //transfer
        payable(msg.sender).transfer(address(this).balance);

        //send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send failed");

        //call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not the owner!");
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    // what happens if someone sends this contract ETH without calling the fund function

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
