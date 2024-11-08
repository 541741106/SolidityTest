// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//FundMe额外功能
// 1，让FundMe的参与者，基于mapping来领取相应数量的通证
// 2，让FundMe的参与者，transfer通证
// 3，在使用完成后，burn通证


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "./FundMe.sol";

contract FundTokenERC20 is ERC20 {
    FundMe fundMe;

    constructor(string memory _name, string memory _symbol, address fundMeAddress) ERC20(_name, _symbol) {
        fundMe = FundMe(fundMeAddress);
    }

    // 1，让FundMe的参与者，基于mapping来领取相应数量的通证(保证在筹款器内执行)
    function mint(uint256 amountToMint) public {
        require(fundMe.fundersToAmount(msg.sender) >= amountToMint, "You don't have enough amount to mint");
        require(fundMe.getFundSuccess(), "The FundMe is not completed yet");
        _mint(msg.sender, amountToMint);
        uint256 fundAfterMint = fundMe.fundersToAmount(msg.sender) - amountToMint;
        fundMe.setFunderToAmount(msg.sender, fundAfterMint);
    }

    //function transfer已经在ERC20中实现且没有额外操作，所以不重写了

    // 3，在使用完成后，burn通证(保证在筹款器内执行)
    function claim(uint256 amountToClaim) public {
        //complete claim
        require(balanceOf(msg.sender) >= amountToClaim, "You don't have enough ERC20 tokens");
        require(fundMe.getFundSuccess(), "The FundMe is not completed yet");
        /*在具体场景中完成*/
        _burn(msg.sender, amountToClaim);
    }
}