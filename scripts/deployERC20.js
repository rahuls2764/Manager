const { ethers } = require("hardhat");

async function main() {
    const MyToken = await ethers.getContractFactory("MyToken");
    const token = await MyToken.deploy(1000000); // 1 million tokens
    await token.deployed();
  
    console.log("✅ MyToken deployed at:", token.address);
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
  
  //0x654247D1d16dB0002D6592A4d7CD30AD0a1DD2aF