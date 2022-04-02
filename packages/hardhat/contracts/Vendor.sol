pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
   function buyTokens() public payable {
    require(msg.value > 0, 'ETH used to buy token must be greater than 0');

    uint256 tokenToBuy = msg.value * tokensPerEth;

    yourToken.transfer(msg.sender, tokenToBuy);

    emit BuyTokens(msg.sender, msg.value, tokenToBuy);

  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

  function withdraw() public onlyOwner {
  uint256 ethToWithdraw = address(this).balance;
  require(ethToWithdraw > 0, 'No ETH to withdraw');

  payable(msg.sender).transfer(ethToWithdraw);
}

  // ToDo: create a sellTokens() function:

  function sellTokens(uint256 tokenToSell) public {
  require(tokenToSell > 0, 'You need to have at least some tokens');

  // Calculate the needed ETH amount
  uint256 ethSold = tokenToSell / tokensPerEth;

  require(address(this).balance >= ethSold, 'Not enough ETH to buy from Vendor');

  // Transfer Token from user to Vendor contract
  yourToken.transferFrom(msg.sender, address(this), tokenToSell);

  payable(msg.sender).transfer(ethSold);

}

}
