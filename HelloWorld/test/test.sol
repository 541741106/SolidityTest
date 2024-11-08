// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


// 结构体 struct
// 数组 array
// 映射 mapping

contract HelloWorld {
    bool boolVar_1 = true;
    bool boolVar_2 = false;

    string strVar = "Hello World!";

    struct Info {
        string phrase;
        uint256 id;
        address addr;
    }

    Info[] infos;

    mapping(uint256 id => Info info) infoMapping;

    function sayHello(uint256 _id) public view returns(string memory) {
        //return strVar;
        //return addinfo(strVar);

        //判断是否存在这个id，思路是判断info的地址是否为空
        if (infoMapping[_id].addr == address(0x0)) {
            return addinfo(strVar);
        } else {
            return infoMapping[_id].phrase;
        }

        //遍历数组的方式
        /*
        for(uint256 i = 0; i < infos.length; ++i) {
            if (infos[i].id == _id) {
                return addinfo(infos[i].phrase);
            }
        }
        return addinfo(strVar);
        */
    }

    /*函数对区块链状态的访问权限
    view 只读取区块链状态 
    pure 不依赖区块链状态的函数，函数内不能读取或修改区块链上的状态变量
    payable 可以在调用时接收以太币，否则会拒绝交易
    immutable 声明不可变的状态变量
    */

    /*存储模式
    1, storage(永久性存储)
    2, memory(暂存)
    3, calldata(暂存)
    4, stack
    5, codes
    6, logs
    */

    function setHelloWorld(string memory newString, uint256 _id) public {
        Info memory info = Info(newString, _id, msg.sender);
        infoMapping[_id] = info;
        infos.push(info);
    } 

    function addinfo(string memory helloWorldString) internal pure returns(string memory) {
        return string.concat(helloWorldString, "from my contract.");
    }

}