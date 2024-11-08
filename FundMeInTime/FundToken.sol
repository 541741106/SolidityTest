// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken {
    //通证所需信息
    //1，通证的名字
    string public tokenName;
    //2，通证的简称
    string public tokenSymbol;
    //3，通证的发行数量
    uint256 public totalSupply;     
    //4，owner的地址
    address public owner;
    //5，balance address => uint256
    mapping(address => uint256) public balances;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }

    //mint函数：获取通证
    function mint(uint256 amountToMint) public {
        balances[msg.sender] += amountToMint; //不需要像transfer ETH一样transfer，只需要修改数量，这也是token和coin的区别
        totalSupply += amountToMint;
    } 

    //transfer函数：transfer通证
    function transfer(address toAddress, uint256 amount) public {
        require(balances[msg.sender] >= amount, "You don't have enough balance to transfer");
        balances[msg.sender] -= amount;
        balances[toAddress] += amount;
    }

    //balanceOf：查看某一地址的通证数量
    function balanceOf(address addr) view public returns(uint256) {
        return balances[addr];
    }

}