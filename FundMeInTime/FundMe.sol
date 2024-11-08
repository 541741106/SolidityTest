// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


//1, 创建一个收款函数
//2, 记录投资人并查看
//3, 在锁定期内(一段时间)内，如果筹款达到目标值，生产商可以提款
//4, 在锁定期内(一段时间)内，如果没有达到目标值，投资人可以退款

contract FundMe { 


    mapping (address => uint256) public fundersToAmount; //记录投资人

    uint256 constant MINIMAL_VALUE_ETH = 100 * 10 ** 18; //单位是wei
    //uint256 MINIMAL_VALUE_USD = ;//通过预言机Oracle获得通证的现实价格

    uint256 constant TARGET = 1000 * 10 * 18;

    address owner; //合约所有者，相当于管理员，让一些函数只能被owner调用

    //设置锁定期
    uint256 deploymentTimestamp; //起始时间
    uint256 lockTime; //锁定长度

    AggregatorV3Interface internal dataFeed;
    //构造器
    constructor(uint256 _lockTime) {
        //sepolia testnet的ETH转USD的价格
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;//部署时的发送者为owner

        deploymentTimestamp = block.timestamp; //开始时间为合约部署时间,这里的block是部署时的区块
        lockTime = _lockTime;
    }

    function transferOwnership(address newOwner) public {
        //设定只能被owner调用
        require(msg.sender == owner, "This function can only be called by owner");
        owner = newOwner;
    }

    //         payable关键字表示可以接受原生通证(native token)
    function fund() external payable {
        //以ETH为单位
        //require(msg.value >= MINIMAL_VALUE_ETH, "Send more ETH"); //如果condition是false，那么操作会被revert，然后输出字符串，可以用来控制最小值
        //以USD为单位
        require(convertEthToUsd(msg.value) >= MINIMAL_VALUE_ETH, "Send more USD");
        require(block.timestamp < deploymentTimestamp + lockTime, "Window closed");//这里的block是调用fund函数的区块

        fundersToAmount[msg.sender] = msg.value; //用key记录投资人，用value记录投资值
    }

     /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns(uint256) {
        //ETH amount * price = value
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        //ethAmount单位为wei，price单位为(precision)
        return ethAmount * ethPrice / (10 ** 8);
    }

    //目标值
    //使用require判断是否超过锁定期
    function getFund() external {
        require(convertEthToUsd(address(this).balance/*单位为wei*/) >= TARGET /*单位为USD*/, "Target is not reached"); //判断是否达到目标值
        require(msg.sender == owner, "This function can only be called by owner");
        require(block.timestamp > deploymentTimestamp + lockTime, "Window not closed"); //判断是否超过锁定期
        //三种转账方式

        //transfer 纯转账 transfer ETH and revert if failed
        //addr.transfer(value)
        payable(msg.sender/*默认的地址是不能payable的因此要强制转换*/).transfer(address(this).balance);

        //send 纯转账。如果转载成功返回true，失败返回false
        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "Transaction failed");

        //call 带有data的转账，理论来说所有转账都能使用，也是被官方推荐的
        //可以返回function的返回值和一个bool值，如果成功为true
        //(bool, result) = addr{value: value}.call("数据")
        bool success2;
        (success2, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success2, "Transaction failed");
    }

    //筹集资金未成功，退款
    //使用修改器判断是否超过锁定期
    function refund() external windowClosed {
        require(convertEthToUsd(address(this).balance) < TARGET, "Target is reached, cannot refund");
        uint256 amount = fundersToAmount[msg.sender];
        require(amount > 0, "You haven't funded");
        bool success;
        (success, ) = payable (msg.sender).call{value: amount}("");
        require(success, "Refund failed");
        fundersToAmount[msg.sender] = 0;
    }

    //修改器，可以增加服用程度，比如也可以把判断是否是owner也写成modifier
    modifier windowClosed() {
        require(block.timestamp > deploymentTimestamp + lockTime, "Window not closed"); //判断是否超过锁定期
        _; //表示先执行上面的判断，再执行函数中的语句，类似于装饰器了
    }
}