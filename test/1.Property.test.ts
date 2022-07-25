import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("Box", function () {
  let box:Contract;

  beforeEach(async function () {
    const Box = await ethers.getContractFactory("Property")
    box = await Box.deploy()
    await box.deployed()
  })
})