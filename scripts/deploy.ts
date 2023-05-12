import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;

  const [owner] = await ethers.getSigners();
  const tangleCon23URI = "https://arweave.net/e6GaXSMjnu06fkiN7KpgREL5xIhVpghiLHddTmZEdaM/";

  const Award = await ethers.getContractFactory("TangleConAwards");
  const award = await Award.deploy(".json");
  const contract = await award.deployed();

  await contract.mapAwardEditionURI(1, tangleCon23URI);
  await contract.mapAwardID(1, 2, 1);
  await contract.airDropAward(2, owner.address);

  console.log(
    `tangleConTest deployed to ${award.address} at ${unlockTime}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
