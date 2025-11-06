import { expect } from "chai";
import { ethers } from "hardhat";
import { MultiManagedAccess } from "../typechain-types";

describe("MultiManagedAccess", function () {
  let multiManager: MultiManagedAccess;
  let manager1: any, manager2: any, manager3: any, outsider: any;

  beforeEach(async function () {
    [manager1, manager2, manager3, outsider] = await ethers.getSigners();

    const MultiManagerFactory = await ethers.getContractFactory(
      "MultiManagedAccess"
    );
    multiManager = (await MultiManagerFactory.deploy([
      manager1.address,
      manager2.address,
      manager3.address,
    ])) as MultiManagedAccess;
  });

  it("should revert if non-manager tries to confirm", async function () {
    await expect(multiManager.connect(outsider).confirm()).to.be.revertedWith(
      "You are not a manager"
    );
  });

  it("should revert if not all managers confirmed before setting reward", async function () {
    await multiManager.connect(manager1).confirm();

    await expect(
      multiManager.connect(manager1).setRewardPerBlock(100)
    ).to.be.revertedWith("Not all managers confirmed yet");
  });

  it("should allow setting reward after all managers confirmed", async function () {
    await multiManager.connect(manager1).confirm();
    await multiManager.connect(manager2).confirm();
    await multiManager.connect(manager3).confirm();

    await expect(multiManager.connect(manager1).setRewardPerBlock(777)).to.not
      .be.reverted;

    const reward = await multiManager.rewardPerBlock();
    expect(reward).to.equal(777);
  });
});
