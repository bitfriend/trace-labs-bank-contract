const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StakingToken", function () {
  const NAME = "StakingToken";
  const SYMBOL = "XYZ";
  const TIME_UNIT = 4; // in seconds
  const SUPPLY = ethers.utils.parseEther("1000");
  let stakingToken;

  beforeEach(async function() {
    const StakingToken = await ethers.getContractFactory("StakingToken");
    stakingToken = await StakingToken.deploy(NAME, SYMBOL, TIME_UNIT, SUPPLY);
    const [owner, customer1, customer2] = await ethers.getSigners();
    await stakingToken.transfer(customer1.address, 1000);
    await stakingToken.transfer(customer2.address, 4000);
  });

  it("Should not deposit after deposit time ellapsed", () => new Promise(async (resolve, reject) => {
    const [owner, customer1] = await ethers.getSigners();
    setTimeout(async () => {
      let depositable;
      try {
        const depositTx = await stakingToken.connect(customer1).createStake(1000);
        await depositTx.wait();
        depositable = true;
      } catch (e) {
        depositable = false;
      } finally {
        expect(depositable).to.equal(false);
        resolve();
      }
    }, TIME_UNIT * 1000 * 1.5);
  }));

  it("Should take the 1st reward", () => new Promise(async (resolve, reject) => {
    const [owner, customer1] = await ethers.getSigners();
    setTimeout(async () => {
      const depositTx = await stakingToken.connect(customer1).createStake(1000);
      await depositTx.wait();
      expect(await stakingToken.stakeOf(customer1.address)).to.equal(1000);
    }, 100);
    setTimeout(async () => {
      const withdrawTx = await stakingToken.connect(customer1).removeStake(200);
      await withdrawTx.wait();
      expect(await stakingToken.stakeOf(customer1.address)).to.equal(800);
      resolve();
    }, TIME_UNIT * 1000 * 2);
  }));
});
