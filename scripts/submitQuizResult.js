require("dotenv").config();
const { ethers } = require("ethers");
const managerAbi = require("../artifacts/contracts/Manager.sol/Manager.json").abi;

const provider = new ethers.providers.JsonRpcProvider(process.env.API_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

const managerAddress = "0x76d98776196F121Ce8Bea65beF115Ffd973Bf270"; // Your deployed manager
const manager = new ethers.Contract(managerAddress, managerAbi, wallet);

async function main() {
  const quizId = 0;
  const score = 90;
  const resultIPFSHash = "Qm..."; // Replace with actual IPFS result metadata

  const tx = await manager.submitQuizResult(quizId, score, resultIPFSHash);
  await tx.wait();
  console.log("Quiz result submitted and rewards distributed");
}

main().catch(console.error);
