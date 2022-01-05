require('@nomiclabs/hardhat-waffle')
require('dotenv').config()

task('accounts', 'Prints the list of accounts', async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners()

  for (const account of accounts) {
    console.log(account.address)
  }
})

task('balance', "Prints an account's balance")
  .addParam('account', "The account's index")
  .setAction(async (taskArgs, hre) => {
    const index = taskArgs.account
    const accounts = await hre.ethers.getSigners()
    const account = accounts[index]
    const balance = await account.getBalance()

    console.log(Number(hre.ethers.utils.formatEther(balance)), 'ETH')
  })

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
}
