const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Governanace", () => {
  let governance;
  let owner;
  let member;
  let gardener;

  beforeEach(async () => {
    const Governance = await ethers.getContractFactory("Governance");

    governance = await Governance.deploy();
    await governance.deployed();

    [owner, member, gardener] = await ethers.getSigners();
    await governance.addMember(owner.address);
    await governance.addGardener(gardener.address);
  });

  describe("member", () => {
    it("should allow the owner to add a member", async () => {
      await governance.addMember(owner.address);
      expect(await governance.members(owner.address)).to.equal(true);
    });

    it("should allow the owner to remove the member", async () => {
      await governance.removeMember(owner.address);
      expect(await governance.members(owner.address)).to.equal(false);
    });
  });

  describe("gardener", () => {
    it("should allow the member to add a gardener", async () => {
      await governance.connect(owner).addGardener(owner.address);
      expect(await governance.gardeners(owner.address)).to.equal(true);
    });

    it("should allow the member to remove Gardener", async () => {
      await governance.connect(owner).removeMember(owner.address);
      expect(await governance.members(owner.address)).to.equal(false);
    });
  });

  describe("contribution and withdraw", () => {
    it("should contribute and withdraw", async () => {
      // contributing 100 wei from gardener's account
      await governance.connect(gardener).addContribution({ value: 100 });

      // checking gardener's contribution
      expect(await governance.contributions(gardener.address)).to.equal(100);

      console.log("before", await ethers.provider.getBalance(gardener.address));

      // withdrawing
      await governance.connect(gardener).withdrawReward();

      console.log("after", await ethers.provider.getBalance(gardener.address));
    });
  });
});
