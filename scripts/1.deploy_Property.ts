import { ethers, upgrades } from "hardhat"
// import { upgrades } from "hardhat"

async function main() {

  const Box = await ethers.getContractFactory("Property")
  console.log("Deploying Box...")
  const box = await upgrades.deployProxy(Box, { initializer: 'initialize' })

  console.log(box.address," box(proxy) address")
  console.log(await upgrades.erc1967.getImplementationAddress(box.address)," getImplementationAddress")
  console.log(await upgrades.erc1967.getAdminAddress(box.address)," getAdminAddress")    
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})