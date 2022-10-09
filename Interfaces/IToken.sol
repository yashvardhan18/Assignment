//SPDX-License-Identifier: UNLICENSED
 pragma solidity ^0.8.0;

 interface IToken {

     function initialize(
		address _owner,
		string calldata _name,
		string calldata _symbol,
		uint8 _decimals
		) external;

        function setOwner(address _owner) external;

        function mint(address recipient, uint amount) external;

        function burn(address recipient, uint amount) external;
        
 }