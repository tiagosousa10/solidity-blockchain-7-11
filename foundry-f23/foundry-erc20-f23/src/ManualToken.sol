//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ManualToken {
   function name() public pure returns (string memory) {
      return "ManualToken";
   }

   function totalSupply() public pure returns (uint256) {
      return 100 ether; // -> 
   }

   function decimals() public pure returns (uint8) {
      return 18;
   }
}
