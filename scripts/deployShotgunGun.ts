import fs from "fs";

import { ethers, artifacts } from "hardhat";
import { GNFT } from "../typechain/GNFT";

async function main() {
  const name = "Shotgun";
  const symbol = "SNFT";

  const GNFT = await ethers.getContractFactory("GNFT");
  const gnft = await GNFT.deploy(name, symbol);

  await gnft.deployed();

  console.log("GNFT deployed to:", gnft.address);
  saveContract(gnft, name);
}

function saveContract(gnft: GNFT, name: string) {
  const path = __dirname + `/../shared/gun-contracts/${name.toLowerCase()}Gun`;
  console.log(path)
  if (!fs.existsSync(path)) {
    fs.mkdirSync(path);

    fs.writeFileSync(
      `${path}/address.json`,
      JSON.stringify({ address: gnft.address }, undefined, 2)
    );

    fs.writeFileSync(
      `${path}/abi.json`,
      JSON.stringify(artifacts.readArtifactSync("GNFT"), undefined, 2)
    );
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
