// SPDX-License-Identifier: UNLICENSED
	pragma solidity ^0.8.0;
	import './Interfaces/IToken.sol';
	import '@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol';
	import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
	contract Token is ERC20Upgradeable {

		address public owner;
		uint8 public dec;
		bool public initialized = false;
		
		function initialize(
		address _owner,
		string calldata _name,
		string calldata _symbol,
		uint8 _decimals
		) external initializer {
			require(initialized == false);
			owner = _owner;
			dec = _decimals;
			__ERC20_init_unchained(_name,_symbol);
			initialized = true;
		}
		
		function setOwner(address _owner) external {
			owner = _owner;
		}
		
		function mint(address recipient, uint amount) external {
			_mint(recipient, amount);
		}
		
		function burn(address recipient, uint amount) external {
			_burn(recipient, amount);
		}

		function decimals() public view override(ERC20Upgradeable) returns(uint8){
			return dec;
		}
	}