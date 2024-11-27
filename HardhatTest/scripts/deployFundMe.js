//部署过程
// import ethers.js
// 创建主函数
    //init 2个accounts
    //用第一个account fund
    //check 合约balance
    //用第二个account fund
    //check 合约balance
    //check mappings
// 执行主函数

//引入ehters，并定义为常量
const { ethers } = require("hardhat")

//异步合约
async function main() {
    //创建合约工厂        await表示后面的语句等待执行完成，类似于同步
    const fundMeFactory = await ethers.getContractFactory("FundMe")
    console.log("Contract deploying")
    //从factory部署合约
    const fundMe = await fundMeFactory.deploy(10)//运行FundMe的构造器
    await fundMe.waitForDeployment() //等待入链
    console.log(`contract has been deployed successfully, contract address ${fundMe.target} is`)

    //等待一会儿再验证可以避免区块延迟导致的失败
    fundMe.deploymentTransaction.wait(5) //等待5个区块

    if (hre.network.config.chainID == 11155111 && process.env.ETHERSCAN_API_KEY) {
        console.log("Wait for 5 confirmations")
        await verifyFundme(fundMe.target, [10]) //验证
    } else {
        console.log("Verify skipped")
    }
    
    //以下部分由于没有配置网络所以不能运行，只是作为演示语法
    //init 2个accounts
    const [firstAccount, secondAccount] = await ethers.getSigners() 

    //用第一个account fund
    const fundTx = fundMe.fund({value: ethers.parseEther("0.5")})
    await fundTx.wait() //同样需要等待入链

    //check 合约balance
    const balanceOfContract = await ethers.provider.getBalance(fundMe.target) //默认为第一个地址
    console.log(`Balance: ${balanceOfContract}`)

    //用第二个account fund             换成第二个地址
    const fundTxSecondAccount = fundMe.connect(secondAccount).fund({value: ethers.parseEther("0.5")})
    await fundTxSecondAccount.wait() //同样需要等待入链

    //check 合约balance
    const balanceOfContractSecond = await ethers.provider.getBalance(fundMe.target) //默认为第一个地址
    console.log(`Balance: ${balanceOfContractSecond}`)

    //check mappings
    const firstAccBalance = await fundMe.fundersToAmmount(firstAccount.address)
    const secondAccBalance = await fundMe.fundersToAmmount(secondAccount.address)
    console.log(`Balance of first account: ${firstAccount.address} is ${firstAccBalance}`)
    console.log(`Balance of second account: ${secondAccount.address} is ${secondAccBalance}`)
}

async function verifyFundme(fundMeAddr, args) {

    //自动执行verify
    await hre.run("verify:verify", {
        address: fundMeAddr,
        constructorArguments: args,
    });
}

//运行main.抓取error，
//() => {}表示箭头函数
// main().then().catch((error) => { ... }) 是 Promise 链的一部分，涉及到异步操作的处理。

// main() 调用一个返回 Promise 对象的函数。
// then() 用于处理 Promise 成功的情况。
// catch() 用于捕获 Promise 失败的情况。
// 在这个例子中，catch() 中的 (error) => { ... } 是一个 箭头函数。它用于处理捕获到的错误
main().then().catch((error) => {
    console.error(error)
    process.exit(1)
})

//运行方法 npx hardhat run +文件目录