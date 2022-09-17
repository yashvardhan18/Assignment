// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// SushiBar is the coolest bar in town. You come in with some Sushi, and leave with more! The longer you stay, the more Sushi you get.
//
// This contract handles swapping to and from xSushi, SushiSwap's staking token.
contract SushiBar is ERC20("SushiBar", "xSUSHI"){
    using SafeMath for uint256;
    IERC20 public sushi;
    mapping(address=>uint256) private stakeTime;
    // Define the Sushi token contract
    constructor(address _sushi) public {
        sushi =IERC20( _sushi);
    }

    // Enter the bar. Pay some SUSHIs. Earn some shares.
    // Locks Sushi and mints xSushi
    function enter(uint256 _amount) public {
        // Gets the amount of Sushi locked in the contract
        uint256 totalSushi = sushi.balanceOf(address(this));
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // If no xSushi exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalSushi == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xSushi the Sushi is worth. The ratio will change overtime, as xSushi is burned/minted and Sushi deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalSushi);
            _mint(msg.sender, what);
        }
        // Lock the Sushi in the contract
        stakeTime[msg.sender]=block.timestamp;
        sushi.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your SUSHIs.
    // Unlocks the staked + gained Sushi and burns xSushi
    function leave(uint256 _share) public {
        require(stakeTime[msg.sender]>0,"No amount staked");
        require(block.timestamp>= (stakeTime[msg.sender]+2 days),"Can't be unstaked");
        // Gets the amount of xSushi in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Sushi the xSushi is worth
        uint256 what = _share.mul(sushi.balanceOf(address(this))).div(totalShares);
        if(block.timestamp>(stakeTime[msg.sender]+2 days) && block.timestamp<=(stakeTime[msg.sender]+4 days)){
            what  = what - (what.mul(75).div(100));
            _burn(msg.sender, _share);
            sushi.transfer(msg.sender, what);
        }
        else if(block.timestamp>(stakeTime[msg.sender]+4 days) && block.timestamp<= (stakeTime[msg.sender]+6 days)){
            what = what - (what.mul(50).div(100));
            _burn(msg.sender, _share);
            sushi.transfer(msg.sender, what);
        }
        else if(block.timestamp>(stakeTime[msg.sender]+6 days) && block.timestamp<=(stakeTime[msg.sender]+8 days)){
            what = what - (what.mul(25).div(100));
            _burn(msg.sender, _share);
            sushi.transfer(msg.sender, what);
        }
        else{ 
        _burn(msg.sender, _share);
        sushi.transfer(msg.sender, what);
        }
    }
}