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
  
  //0xF1183239824A955DadB69e93a784EeFA2b2562B5