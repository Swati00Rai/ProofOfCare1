const { ethers } = require("hardhat");

async function main() {
  const ProofOfCare = await ethers.getContractFactory("ProofOfCare");
  const proofOfCare = await ProofOfCare.deploy();

  await proofOfCare.deployed();

  console.log("ProofOfCare contract deployed to:", proofOfCare.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
