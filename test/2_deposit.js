const RollupNC = artifacts.require("RollupNC");
const TestToken = artifacts.require("TestToken");
const DepositManager = artifacts.require("./DepositManager.sol");
var TokenRegistry = artifacts.require("./TokenRegistry.sol");

contract("RollupNC Deposit", async accounts => {
  it("should correctly add valid deposit", async () => {
    let tokenInstance = await TestToken.deployed();
    let rollupInstance = await RollupNC.deployed();
    let depositInstance = await DepositManager.deployed();
    let registryInstance = await TokenRegistry.deployed();

    depositor = accounts[0];
    balance = 100;
    rollupPubKey_x = 0;
    rollupPubKey_y = 0;
    nonce = 0;

    // Register Token
    let result = await registryInstance.registerToken(tokenInstance.address, { from: depositor, value: 10**18 });
    const tokenIndex = await registryInstance.getTokenIdByAddress(tokenInstance.address, { from: depositor });
    
    // Approve Token Spend
    await tokenInstance.approve(depositInstance.address, balance, { from: depositor });
    // Deposit Token
    result = await depositInstance.depositTokens(rollupPubKey_x, rollupPubKey_y, tokenIndex, balance, nonce, { from: depositor });

    // Ensure deposit event was emitted correctly
    eventName = result.logs[0].event;
    logArgs = {
      sender: result.logs[0].args[0],
      pubKey_x: result.logs[0].args[1].toNumber(),
      pubKey_y: result.logs[0].args[2].toNumber(),
      tokenAddr: result.logs[0].args[3].toString(),
      amount: result.logs[0].args[4].toNumber(),
    }

    assert.equal(eventName, "DepositAdded");
    assert.equal(logArgs.sender, depositor);
    assert.equal(logArgs.pubKey_x, rollupPubKey_x);
    assert.equal(logArgs.pubKey_y, rollupPubKey_y);
    assert.equal(logArgs.tokenAddr, tokenIndex);
    assert.equal(logArgs.amount, balance);
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