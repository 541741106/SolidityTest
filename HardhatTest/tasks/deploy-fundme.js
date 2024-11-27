//使用hardhat task完成部署和交互

const { tast } = require("hardhat/config")

//task("").setAction(async(taskArgs, hre) => {})
task("deploy-fundme").setAction(async(taskArgs, hre) => {
    
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
})

async function verifyFundme(fundMeAddr, args) {

    //自动执行verify
    await hre.run("verify:verify", {
        address: fundMeAddr,
        constructorArguments: args,
    });
}

