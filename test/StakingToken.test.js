const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("StakingToken", function () {
  const NAME = "StakingToken";
  const SYMBOL = "XYZ";
  const TIME_UNIT = 5; // in seconds
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
        const depositTx = await stakingToken.connect(customer1).deposit(1000);
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

  it("Should take the rewards of 2 customers", () => new Promise(async (resolve0, reject0) => {
    // 1st customer: 200 * (1000 / (1000 + 4000)) = 40
    // 2nd customer: 200 * (4000 / (1000 + 4000)) + 300 * 100% = 460

    const [owner, customer1, customer2] = await ethers.getSigners();

    const p1 = new Promise((resolve, reject) => setTimeout(async () => {
      const firstTx = await stakingToken.connect(customer1).deposit(1000);
      await firstTx.wait();
      const secondTx = await stakingToken.connect(customer2).deposit(4000);
      await secondTx.wait();
      resolve();
    }, 100));

    const p2 = new Promise((resolve, reject) => setTimeout(async () => {
      const withdrawTx = await stakingToken.connect(customer1).withdraw();
      await withdrawTx.wait();
      expect(await stakingToken.balanceOf(customer1.address)).to.equal(1000 + 40);
      resolve();
    }, TIME_UNIT * 1000 * 2));

    const p3 = new Promise((resolve, reject) => setTimeout(async () => {
      const withdrawTx = await stakingToken.connect(customer2).withdraw();
      await withdrawTx.wait();
      expect(await stakingToken.balanceOf(customer2.address)).to.equal(4000 + 460);
      resolve();
    }, TIME_UNIT * 1000 * 3));

    await Promise.all([p1, p2, p3]);
    resolve0();
  }));
});
