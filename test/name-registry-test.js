const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('NameRegistry', () => {
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
  })

  it('Should register a new name', async () => {
    const name = 'Satoshi Nakamoto'
    const registerNameTx = await nameRegistry.registerName(name, { value: 1000 })
    await registerNameTx.wait()

    expect(await nameRegistry.isNameExists(name)).to.equal(true)

    const record = await getRecord(name)
    expect(record.data).to.equal(name)
  })
})
