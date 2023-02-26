// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.



async function deployContract() {
  
  // Create a contract factory and deploy the contract
  const factory = await ethers.getContractFactory("Governance");
  const contract = await factory.deploy();
  await contract.deployed();
  console.log("Contract deployed at address:", contract.address);
}

deployContract();
