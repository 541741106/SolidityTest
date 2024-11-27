// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Parent {
    uint256 public a;
    uint256 private b = 10; //private的变量或方法无法被继承

    constructor(uint256 _a) {
        a = _a;
    }

    function addOne() public {
        a++;
    }

    //virtual关键字表示虚函数，拥有此关键字的函数的合约必须是abstract的
    //子函数必须override这个虚函数，否则也将是abstract的
    //同时父函数中的没有添加virtual关键字的函数不能overr
    //但如果父合约中的virtual函数有函数体，则子合约不需要重写
    function addSome(uint256 some) public virtual; 
}

contract Child is Parent {

    constructor(uint256 __a) Parent(__a){
    }

    function addTwo() public {
        a += 2;
    }

    function addSome(uint256 some) public override {
        a += some;
    }
}
