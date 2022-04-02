// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

//defining the contract
contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;

  //state variables

  uint256 public constant threshold = 1 ether;

  uint256 public deadline = block.timestamp + 24 hours;

  bool public openForWithdraw;

  //events

  event Stake(address sender, uint256 amount);

  //Modifiers section

  //deadlinereached modifier
  modifier deadlineReached( bool requireReached ) {
    uint256 timeRemaining = timeLeft();
    if( requireReached ) {
      require(timeRemaining <= 0, "Deadline is not reached yet");
    } else {
      require(timeRemaining > 0, "Deadline is already reached");
    }
    _;
  }

//stakeNotCompleted modifier
  modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }
  
  constructor(address exampleExternalContractAddress) {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  function stake() public payable deadlineReached(false) stakeNotCompleted {
    // update the user's balance
    balances[msg.sender] += msg.value;
    
    // emit the event to notify the blockchain that we have correctly Staked some fund for the user
    emit Stake(msg.sender, msg.value);
  }

  function execute() public stakeNotCompleted {
    uint256 contractBalance = address(this).balance;

    if (contractBalance >= threshold) {

    exampleExternalContract.complete{value: contractBalance}();
    } else {
      // if the `threshold` was not met, allow everyone to call a `withdraw()` function
      openForWithdraw = true;
    }
  }

  function withdraw() public deadlineReached(true) stakeNotCompleted {

    require(openForWithdraw, "Not open for withdraw");

      // get the sender balance
      uint256 userBalance = balances[msg.sender];

      // check if the sender has a balance to withdraw
      require(userBalance > 0, "userBalance is 0");

      // reset the sender's balance
      balances[msg.sender] = 0;

      // transfer sender's balance to the `_to` address
      (bool sent, ) = payable(msg.sender).call{value: userBalance}("");

      // check transfer was successful
      require(sent, "Failed to send to address");
  }

  function timeLeft() public view returns (uint256) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  receive() external payable {
      stake();
  }
}