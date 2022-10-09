// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import '@chainlink/contracts/src/v0.8/VRFConsumerBase.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract gambling is VRFConsumerBase,Ownable
{   
    uint256 Players;
    uint256 EntryFee;
    uint256 count;
    struct playerInfo{
        address player;
        uint256 feePaid;
    }
    mapping(uint256 => playerInfo)private playerAmount;

    constructor(address _VRFCoordinator,address LINK) VRFConsumerBase(_VRFCoordinator,LINK){}  
    

    function initialize(uint256 _Players, uint256 _EntryFee) external onlyOwner{
        require(_Players >= 3,"Min. player should be 3");
        Players = _Players;
        EntryFee = _EntryFee;
    }

    function enterGame() external {
        require(msg.sender != owner());
        require(msg.value>=EntryFee,"Invalid fee");
        playerAmount[count] = playerInfo(msg.sender,msg.value);
        count++;
    }

    
}