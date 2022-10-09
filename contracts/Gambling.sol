// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import '@chainlink/contracts/src/v0.8/VRFConsumerBase.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract gambling is VRFConsumerBase,Ownable
{   
    uint256 Players;
    uint256 EntryFee;
    uint256 count;
    uint256 randomResult;
    address winner;
    bytes32 keyHash = 0x0476f9a745b61ea5c0ab224d3a6e4c99f0b02fce4da01143a4f70aa80ae76e8a;
    uint256 linkFee = 0.1*10**18;
    struct playerInfo{
        address player;
        uint256 feePaid;
    }
    mapping(uint256 => playerInfo)private playerAmount;
    mapping(address => uint256) public playerFee;

    constructor(address _VRFV2Coordinator,address LINK) VRFConsumerBase(_VRFV2Coordinator,LINK){}  
    

    function initialize(uint256 _Players, uint256 _EntryFee) external onlyOwner{
        require(_Players >= 3,"Min. player should be 3");
        Players = _Players;
        EntryFee = _EntryFee;
    }

    function enterGame() external payable{
        require(msg.sender != owner());
        require(msg.value>=EntryFee,"Invalid fee");
        require(count<=Players);
        playerAmount[count] = playerInfo(msg.sender,msg.value);
        playerFee[msg.sender] = msg.value;
        count++;
    }

    function chooseNumber() external onlyOwner returns (bytes32 requestId) {
        return requestRandomness(keyHash, linkFee);
         
    }
    function viewWinner() public returns(address) {
        winner = playerAmount[randomResult].player;
        return winner;
    }

    function fulfillRandomness(bytes32 _requestId, uint256 randomness) internal override(VRFConsumerBase) {
        randomResult = (randomness%Players) + 1;
    }

    function withdrawFromGame() external {
        require(count!=Players);
        uint256 fee = playerFee[msg.sender];
        (bool sent, bytes memory data) = msg.sender.call{value:fee}("");
        require(sent,"Prize Transfer failed!");

    }

    function claimPrize()external {
        require(msg.sender != owner());
        uint256 prize = (address(this).balance*99)/100;
        (bool sent, bytes memory data) = msg.sender.call{value:prize}("");
        require(sent,"Prize Transfer failed!");
    }

     function withdrawFee() external onlyOwner{
        uint balance = address(this).balance;
        (bool sent, bytes memory data) = owner().call{value:balance}("");
        require(sent,"Ether Transfer failed!");

    }
}
