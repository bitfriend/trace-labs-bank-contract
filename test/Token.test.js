const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token", function () {
  const NAME = "Token";
  const SYMBOL = "XYZ";
  const AMOUNT = ethers.utils.parseEther("1.0");
  let token;

  beforeEach(async function() {
    const Token = await ethers.getContractFactory("Token");
    token = await Token.deploy(NAME, SYMBOL);
  });

  it("Should have a name", async function () {
    expect(await token.name()).to.equal(NAME);
  });

  it("Should have a symbol", async function () {
    expect(await token.symbol()).to.equal(SYMBOL);
  });

  it("Should take ownership of a token", async function () {
    const [owner, customer] = await ethers.getSigners();
    await token.mint(customer.address, AMOUNT);
    expect(await token.balanceOf(customer.address)).to.equal(AMOUNT);
  });
});
