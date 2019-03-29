const RollupNC = artifacts.require("RollupNC");
const TestToken = artifacts.require("TestToken");

contract("RollupNC Deposit", async accounts => {
  it("should correctly add valid deposit", async () => {
    let tokenInstance = await TestToken.deployed();
    let rollupInstance = await RollupNC.deployed();

    depositor = accounts[0];
    amount = 100;
    rollupPubKey = 0;

    await tokenInstance.approve(rollupInstance.address, amount, { from: depositor });
    let result = await rollupInstance.depositTokens(tokenInstance.address, amount, rollupPubKey, { from: depositor });

    // Ensure deposit event was emitted correctly
    eventName = result.logs[0].event;
    logArgs = {
      sender: result.logs[0].args[0],
      pubKey: result.logs[0].args[1].toNumber(),
      tokenAddr: result.logs[0].args[2],
      amount: result.logs[0].args[3].toNumber(),
    }

    assert.equal(eventName, "DepositAdded");
    assert.equal(logArgs.sender, depositor);
    assert.equal(logArgs.pubKey, rollupPubKey);
    assert.equal(logArgs.tokenAddr, tokenInstance.address);
    assert.equal(logArgs.amount, amount);
  });

  it("should fail without any token allowance", async () => {
    // TODO
  });

  it("should fail without sufficient token allowance", async () => {
    // TODO
  });

  it("should update valid deposit root successfully", async () => {
    // TODO
  });

  it("should reject non-operator accounts trying to update deposit root", async () => {
    // TODO
  });
});