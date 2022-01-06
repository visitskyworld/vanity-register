const { expect } = require('chai')
const { ethers } = require('hardhat')

describe('LifespanFee', () => {
  let lifespanFee
  let owner, addr1

  beforeEach(async () => {
    [owner, addr1] = await ethers.getSigners()

    const LifespanFeeDummyImpl = await ethers.getContractFactory('LifespanFeeDummyImpl')
    lifespanFee = await LifespanFeeDummyImpl.deploy()
    await lifespanFee.deployed()
  })

  it('Should return new fee parameters after changing them', async () => {
    expect(await lifespanFee.feePerByte()).to.equal(2)
    const setFeePerByteTx = await lifespanFee.setFeePerByte(5)
    await setFeePerByteTx.wait()
    expect(await lifespanFee.feePerByte()).to.equal(5)

    expect(await lifespanFee.feePerSecond()).to.equal(5)
    const setFeePerSecondTx = await lifespanFee.setFeePerSecond(2)
    await setFeePerSecondTx.wait()
    expect(await lifespanFee.feePerSecond()).to.equal(2)
  })

  it('Should transfer ownership', async () => {
    expect(await lifespanFee.owner()).to.equal(owner.address)
    const transferOwnershipTx = await lifespanFee.transferOwnership(addr1.address)
    await transferOwnershipTx.wait()
    expect(await lifespanFee.owner()).to.equal(addr1.address)
  })

  it('Should calculate the lifespan value correctly', async () => {
    const length = 7
    const seconds = 1000
    const value = await lifespanFee.estimate(length, seconds)
    expect(await lifespanFee.lifespan(length, value)).to.equal(seconds)
  })
})
