const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('AddressRegistry', () => {
  const name = 'Vitalik Buterin'
  const address = 'd9145CCE52D386f254917e481eB44e9943F39138'
  const seconds = 100

  let value
  let addressRegistry
  let addr1

  const getRecord = async (name) => {
    const label = await addressRegistry.getRecordLabel(name)
    return await addressRegistry.records(label)
  }

  before(async () => {
    [, addr1] = await ethers.getSigners()

    const LifespanFeeDummyImpl = await ethers.getContractFactory('LifespanFeeDummyImpl')
    const lifespanFee = await LifespanFeeDummyImpl.deploy()
    await lifespanFee.deployed()

    const AddressRegistry = await ethers.getContractFactory('AddressRegistry')
    addressRegistry = await AddressRegistry.deploy(lifespanFee.address)
    await addressRegistry.deployed()

    value = await addressRegistry.estimateRegistrationFee(seconds)
  })

  it('Should check the addresses for correctness', async () => {
    expect(await addressRegistry.isAddressValid(address)).to.equal(true)
    expect(await addressRegistry.isAddressValid('d9145CCE52D386f254917e48')).to.equal(false)
    expect(await addressRegistry.isAddressValid('!@#$%^&*)(_+!#^%&#&*!@&@&^$<>?>??><>?</>')).to.equal(false)
  })

  it(`Should register a new address for ${seconds} seconds`, async () => {
    const registerAddressTx = await addressRegistry.registerAddress(name, address, { value })
    await registerAddressTx.wait()

    expect(await addressRegistry.isAddressExists(name)).to.equal(true)
  })

  it('Should transfer ownership of the record', async () => {
    const transferAddressOwnershipTx = await addressRegistry.transferAddressOwnership(name, addr1.address)
    await transferAddressOwnershipTx.wait()

    const record = await getRecord(name)
    expect(record.owner).to.equal(addr1.address)
  })

  it('Should bring the timestamp of the next block above the record lifespan', async () => {
    const toIncrease = seconds + 1
    await network.provider.send('evm_increaseTime', [toIncrease])

    const prevBlock = await network.provider.send('eth_getBlockByNumber', ['latest', false])
    await network.provider.send('evm_mine')
    const nextBlock = await network.provider.send('eth_getBlockByNumber', ['latest', false])

    const timestampDiff = Number(nextBlock.timestamp) - Number(prevBlock.timestamp)
    expect(timestampDiff).to.greaterThanOrEqual(toIncrease)
  })

  it('Should make sure that the record is expired', async () => {
    expect(await addressRegistry.isAddressExpired(name)).to.equal(true)
  })

  it('Should clear the expired record and return the locked balance to the owner', async () => {
    const oldBalance = await addr1.getBalance()
    const clearExpiredAddressTx = await addressRegistry.clearExpiredAddress(name)
    await clearExpiredAddressTx.wait()
    const newBalance = await addr1.getBalance()

    expect(newBalance.sub(oldBalance)).to.equal(value)
    expect(await addressRegistry.isAddressExists(name)).to.equal(false)
  })
})
