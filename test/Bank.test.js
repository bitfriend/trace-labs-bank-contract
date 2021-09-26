const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token", function () {
  const NAME = "Token";
  const SYMBOL = "XYZ";
  const TIME_UNIT = 4; // in seconds
  let token, bank;

  beforeEach(async function() {
    const Token = await ethers.getContractFactory("Token");
    token = await Token.deploy(NAME, SYMBOL);
    const Bank = await ethers.getContractFactory("Bank");
    bank = await Bank.deploy(token.address, TIME_UNIT);
  });

  it("Should not deposit after time unit ellapsed", () => new Promise(async (resolve, reject) => {
    const [owner, customer] = await ethers.getSigners();
    setTimeout(async () => {
      try {
        const value = ethers.utils.parseEther("1.0");
        await token.approve(customer.address, value);
        const depositTx = await bank.connect(customer).deposit({ value });
        await depositTx.wait();
        reject();
      } catch (e) {
        resolve();
      }
    }, TIME_UNIT * 1000 * 1.5);
  }));

  it("Should take the 1st reward", () => new Promise(async (resolve, reject) => {
    const [owner, customer] = await ethers.getSigners();
    setTimeout(async () => {
      const value = ethers.utils.parseEther("1.0");
      await token.approve(customer.address, value);
      const depositTx = await bank.connect(customer).deposit({ value });
      await depositTx.wait();
    }, 100);
    setTimeout(async () => {
      const amount = ethers.utils.parseEther("0.2");
      const withdrawTx = await bank.connect(customer).withdraw(amount);
      await withdrawTx.wait();
      resolve();
    }, TIME_UNIT * 1000 * 2);
  }));
});
