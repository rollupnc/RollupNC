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
    
    // Ensure deposit is correctly added to the pending deposits list
    result = await rollupInstance.getPendingDeposits.call();

    pendingDeposits = [];
    pendingDeposits[0] = {
      sender: result['0'][0],
      pubKey: result['1'][0].toNumber(),
      tokenAddr: result['2'][0],
      amount: result['3'][0].toNumber(),
    }

    assert.equal(result['0'].length, 1);
    assert.equal(pendingDeposits[0].sender, depositor);
    assert.equal(pendingDeposits[0].pubKey, rollupPubKey);
    assert.equal(pendingDeposits[0].tokenAddr, tokenInstance.address);
    assert.equal(pendingDeposits[0].amount, amount);
  });

  it("should fail without any token allowance", async () => {
    // TODO
  });

  it("should fail without sufficient token allowance", async () => {
    // TODO
  });

  it("should update deposit merkle root successfully", async () => {
    // TODO
  });

  it("should clear pending deposit (only one) when operator collects it for rollup sidechain", async () => {
    let rollupInstance = await RollupNC.deployed();

    operator = accounts[0];
    let result = await rollupInstance.rollupPendingDeposits({ from: operator });

    // Should emit event
    eventName = result.logs[0].event;
    logArgs = {
      pendingDepositCount: result.logs[0].args[0].toNumber(),
    }

    assert.equal(eventName, "DepositRollup");
    assert.equal(logArgs.pendingDepositCount, 1);


    // Should have cleared pending deposit list
    result = await rollupInstance.getPendingDeposits.call();
    assert.equal(result['0'].length, 0);
  });

  it("should clear pending deposits (several) when operator collects them for rollup sidechain", async () => {
    // TODO
  });

  it("should reject non-operator accounts trying to clear pending deposits", async () => {
    // TODO
  });

  it("should track new deposits correctly after previously clearing them", async () => {
    // TODO
  });

});