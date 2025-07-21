const { ethers } = require("hardhat");

async function main() {
  // Replace with your token contract address
  const tokenAddress = "0xYourTokenContractAddressHere";

  const CharityBridge = await ethers.getContractFactory("CharityBridge");
  const charityBridge = await CharityBridge.deploy(tokenAddress);

  await charityBridge.deployed();
  

  console.log("CharityBridge contract deployed to:", charityBridge.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
