require("dotenv").config();
const { ethers } = require("hardhat");

async function main() {
  const tokenAddress = "0x80632E33029fc46F3dEF09d79ce46a3AEA58A851";
  const recipient = "0xd2AA84AF3Aba300908C6B1Ae81df3b7Db2edD06B";

  const MyToken = await ethers.getContractAt("MyToken", tokenAddress);
  const tx = await MyToken.transfer(recipient, ethers.utils.parseUnits("1000", 18));
  await tx.wait();

  console.log(`✅ Sent 1000 MTK to ${recipient}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
