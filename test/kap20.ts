import { expect } from "chai";
import { ethers } from "hardhat";

import { Bullet } from "../typechain/Bullet";
import { State } from "../utils/state";

describe("Bullet", function () {
  const state = new State();
  let bulletFactory: Bullet;

  before(async () => {
    const factory = await ethers.getContractFactory("Bullet");
    bulletFactory = await factory.deploy("premium bullet", "PB");
    await bulletFactory.deployed();

    const [deployer, account1, account2] = await ethers.getSigners();
    state.set("Deployer", deployer);
    state.set("Account1", account1);
    state.set("Account2", account2);
  });

  it("Should mint bullet success", async function () {
    await bulletFactory.connect(state.get("Deployer")).deposit(100);
    await bulletFactory.connect(state.get("Account1")).deposit(200);
    await bulletFactory.connect(state.get("Account2")).deposit(300);

    const balanceDeployer = await bulletFactory.balanceOf(
      state.get("Deployer")["address"]
    );
    const balanceAccount1 = await bulletFactory.balanceOf(
      state.get("Account1")["address"]
    );
    const balanceAccount2 = await bulletFactory.balanceOf(
      state.get("Account2")["address"]
    );

    expect(balanceDeployer).to.equal(100);
    expect(balanceAccount1).to.equal(200);
    expect(balanceAccount2).to.equal(300);
  });

  it("Should burn bullet success", async function () {
    await bulletFactory.connect(state.get("Deployer")).withdraw(50);
    const balance = await bulletFactory.balanceOf(
      state.get("Deployer")["address"]
    );
    expect(balance).to.equal(50);
  });
});
