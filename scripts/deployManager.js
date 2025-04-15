const { ethers } = require("hardhat");
require("dotenv").config();

async function main() {
  const nftAddress = "0x74256a78e73e7a937E156F42C5A0aE70A9Ac9080";
  const tokenAddress = "0x654247D1d16dB0002D6592A4d7CD30AD0a1DD2aF";

  const Manager = await ethers.getContractFactory("Manager");
  const manager = await Manager.deploy(nftAddress, tokenAddress);
  await manager.deployed();

  console.log("Manager contract deployed at:", manager.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
 
//0x76d98776196F121Ce8Bea65beF115Ffd973Bf270