import { expect } from "chai";
import { ethers } from "hardhat";

describe("GNFT", function () {
  it("Should create GNFT", async function () {
    const Gnft = await ethers.getContractFactory("GNFT");
    const gnft = await Gnft.deploy();
    await gnft.deployed();

    await gnft.create(1, "https://google.com");
    const totalSupply = await gnft.totalSupply();

    expect(totalSupply).to.equal(1);
  });
});
