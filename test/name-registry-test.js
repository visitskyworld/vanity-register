const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('NameRegistry', () => {
  const name = 'Satoshi Nakamoto'
  const seconds = 100

  let value
  let nameRegistry
  let owner, addr1

  const getRecord = async (name) => {
    const label = await nameRegistry.getRecordLabel(name)
    return await nameRegistry.records(label)
  }

  before(async () => {
    [owner, addr1] = await ethers.getSigners()

    const LifespanFeeDummyImpl = await ethers.getContractFactory('LifespanFeeDummyImpl')
    const lifespanFee = await LifespanFeeDummyImpl.deploy()
    await lifespanFee.deployed()

    const NameRegistry = await ethers.getContractFactory('NameRegistry')
    nameRegistry = await NameRegistry.deploy(lifespanFee.address)
    await nameRegistry.deployed()

    value = await nameRegistry.estimateRegistrationFee(name, seconds)
  })

  it(`Should register a new name for ${seconds} seconds`, async () => {
    const registerNameTx = await nameRegistry.registerName(name, { value })
    await registerNameTx.wait()

    expect(await nameRegistry.isNameExists(name)).to.equal(true)
  })

  it('Should not register the same name', async () => {
    await expect(
      nameRegistry.connect(addr1).registerName(name, { value })
    ).to.be.revertedWith('RecordRegistry: the record has not expired yet')
  })

  it('Should have the correct record fields after registration', async () => {
    const record = await getRecord(name)

    expect(record.data).to.equal(name)
    expect(record.lifespan).to.equal(seconds)
    expect(record.value).to.equal(value)
    expect(record.owner).to.equal(owner.address)
  })

  it('Should not renew the record since the lifespan has not expired', async () => {
    await expect(
      nameRegistry.renewName(name)
    ).to.be.revertedWith('RecordRegistry: the record cannot be renewed yet')
  })

  it('Should bring the timestamp of the next block closer to the end of record lifespan', async () => {
    const renewThreshold = await nameRegistry.renewThreshold()
    const toIncrease = ethers.BigNumber.from(seconds).sub(renewThreshold).toNumber()
    await network.provider.send('evm_increaseTime', [toIncrease])

    const prevBlock = await network.provider.send('eth_getBlockByNumber', ['latest', false])
    await network.provider.send('evm_mine')
    const nextBlock = await network.provider.send('eth_getBlockByNumber', ['latest', false])

    const timestampDiff = Number(nextBlock.timestamp) - Number(prevBlock.timestamp)
    expect(timestampDiff).to.greaterThanOrEqual(toIncrease)
  })

  it('Should not update the record without being the owner', async () => {
    await expect(
      nameRegistry.connect(addr1).renewName(name)
    ).to.be.revertedWith('RecordRegistry: the caller is not the owner of the record')
  })

  it('Should transfer ownership of the record', async () => {
    const transferNameOwnershipTx = await nameRegistry.transferNameOwnership(name, addr1.address)
    await transferNameOwnershipTx.wait()

    const record = await getRecord(name)
    expect(record.owner).to.equal(addr1.address)
  })

  it('Should renew the record by new owner', async () => {
    const oldTimestamp = (await getRecord(name)).timestamp
    const renewNameTx = await nameRegistry.connect(addr1).renewName(name)
    await renewNameTx.wait()
    const newTimestamp = (await getRecord(name)).timestamp

    expect(newTimestamp.toNumber()).to.greaterThan(oldTimestamp.toNumber())
  })

  it('Should make sure that the record is not expired', async () => {
    expect(await nameRegistry.isNameExpired(name)).to.equal(false)
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
    expect(await nameRegistry.isNameExpired(name)).to.equal(true)
  })

  it('Should clear the expired record and return the locked balance to the owner', async () => {
    const oldBalance = await addr1.getBalance()
    const clearExpiredNameTx = await nameRegistry.clearExpiredName(name)
    await clearExpiredNameTx.wait()
    const newBalance = await addr1.getBalance()

    expect(newBalance.sub(oldBalance)).to.equal(value)
    expect(await nameRegistry.isNameExists(name)).to.equal(false)
  })
})
