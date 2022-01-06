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

    const ProtectedNameRegistry = await ethers.getContractFactory('ProtectedNameRegistry')
    protectedNameRegistry = await ProtectedNameRegistry.deploy(lifespanFee.address)
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
})
