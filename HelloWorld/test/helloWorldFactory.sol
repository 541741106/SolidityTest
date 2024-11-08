//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//import {HelloWorld} from "https://github.com/smartcontractkit/Web3_tutorial_Chinese/blob/main/lesson-2/HelloWorld.sol";
import {HelloWorld} from "./test.sol";
//import ... from "@companyName/product/contract" 通过js引入包

contract HelloWorldFactory {
    HelloWorld hw;

    HelloWorld[] hws;

    function createHelloWorld() public {
        hw = new HelloWorld();
        hws.push(hw);
    }

    function getHelloWorldByIndex(uint256 _index) public view returns (HelloWorld){
        return hws[_index];
    }

    function callSayHelloWorldFromFactory(uint256 _index, uint256 _id) 
        public 
        view 
        returns (string memory) {
            return hws[_index].sayHello(_id);
    }

    function callSetHelloWorldFromFactory(uint256 _index, string memory newString, uint256 _id) public {
        hws[_index].setHelloWorld(newString, _id);
    }
}