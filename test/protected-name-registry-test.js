const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('ProtectedNameRegistry', () => {
  const name = 'Gavin Wood'
  const seconds = 100

  let value
  let protectedNameRegistry
  let owner, addr1

  const getRecord = async (name) => {
    const label = await protectedNameRegistry.getRecordLabel(name)
    return await protectedNameRegistry.records(label)
  }

  before(async () => {
    [owner, addr1] = await ethers.getSigners()

    const LifespanFeeDummyImpl = await ethers.getContractFactory('LifespanFeeDummyImpl')
    const lifespanFee = await LifespanFeeDummyImpl.deploy()
    await lifespanFee.deployed()

    const GasStationDummyImpl = await ethers.getContractFactory('GasStationDummyImpl')
    const gasStation = await GasStationDummyImpl.deploy()
    await gasStation.deployed()

    const ProtectedNameRegistry = await ethers.getContractFactory('ProtectedNameRegistry')
    protectedNameRegistry = await ProtectedNameRegistry.deploy(lifespanFee.address, gasStation.address)
    await protectedNameRegistry.deployed()

    value = await protectedNameRegistry.estimateRegistrationFee(name, seconds)
  })

  it('Should not register an unauthorized name', async () => {
    await expect(
      protectedNameRegistry.authorizedRegisterName(name, { value })
    ).to.be.revertedWith('Authorization: account not authorized for this message')
  })

  it('Should authorize the name', async () => {
    const digest = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(name))
    await expect(
      protectedNameRegistry.authorize(digest)
    ).to.be.not.reverted
  })

  it('Should register an authorized name', async () => {
    await expect(
      protectedNameRegistry.authorizedRegisterName(name, { value })
    ).to.be.not.reverted
  })

  it('Should have the correct record fields after registration', async () => {
    const record = await getRecord(name)

    expect(record.data).to.equal(name)
    expect(record.lifespan).to.equal(seconds)
    expect(record.value).to.equal(value)
    expect(record.owner).to.equal(owner.address)
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

  it('Should not register the name due to gas throttling', async () => {
    await expect(
      protectedNameRegistry.throttledRegisterName(name, { value })
    ).to.be.revertedWith('GasPriceLimiter: the gas price should be the same as the one suggested')
  })

  it('Should register the name with the correct gas price set', async () => {
    const gasPrice = await protectedNameRegistry.suggestedGasPrice()
    await expect(
      protectedNameRegistry.connect(addr1).throttledRegisterName(name, { value, gasPrice })
    ).to.be.not.reverted
  })

  it('Should have the correct record fields after registration', async () => {
    const record = await getRecord(name)

    expect(record.data).to.equal(name)
    expect(record.lifespan).to.equal(seconds)
    expect(record.value).to.equal(value)
    expect(record.owner).to.equal(addr1.address)
  })
})
