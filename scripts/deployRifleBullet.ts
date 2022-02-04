import fs from "fs";

import { ethers, artifacts } from "hardhat";
/* eslint-disable */
import { Bullet } from "../typechain/Bullet";

async function main() {
  const name = "Rifle bullet";
  const symbol = "RB";

  const BULLET = await ethers.getContractFactory("Bullet");
  const bullet = await BULLET.deploy(name, symbol);

  await bullet.deployed();

  console.log("Bullet deployed to:", bullet.address);
  saveContract(bullet, name);
}

function saveContract(gnft: Bullet, name: string) {
  const path =
    __dirname + `/../shared/bullet-contracts/${name.toLowerCase()}Gun`;
  console.log(path);
  if (!fs.existsSync(path)) {
    fs.mkdirSync(path);

    fs.writeFileSync(
      `${path}/address.json`,
      JSON.stringify({ address: gnft.address }, undefined, 2)
    );

    fs.writeFileSync(
      `${path}/abi.json`,
      JSON.stringify(artifacts.readArtifactSync("Bullet"), undefined, 2)
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
