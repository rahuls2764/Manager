require("dotenv").config(); // Load environment variables from .env
const { ethers } = require("ethers");
const fs = require("fs");
const path = require("path");

async function main() {
  const alchemyUrl = process.env.API_URL;
  const privateKey = process.env.PRIVATE_KEY;

  // Setup provider and wallet
  const provider = new ethers.providers.JsonRpcProvider(alchemyUrl);
  const wallet = new ethers.Wallet(privateKey, provider);

  // Read the compiled artifact (replace path if needed)
  const contractArtifact = require("../artifacts/contracts/MyNFT.sol/MyNFT.json");

  // Create a ContractFactory and deploy
  const factory = new ethers.ContractFactory(contractArtifact.abi, contractArtifact.bytecode, wallet);
  const contract = await factory.deploy();

  console.log("MyNFT deployed at:", contract.address);

  // Optional: Transfer ownership to Manager contract
  const managerAddress = "0x76d98776196F121Ce8Bea65beF115Ffd973Bf270"; // <- Replace this
  const tx = await contract.transferOwnership(managerAddress);
  await tx.wait();

  console.log("Ownership transferred to Manager contract at:", managerAddress);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});

//0x7d7771659037afb454Ec475Dcbd6248DD29cda06