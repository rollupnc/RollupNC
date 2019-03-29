const TestToken = artifacts.require("TestToken");

contract("TestToken", async accounts => {
  it("should start with all tokens in the deployers' account", async () => {
    let instance = await TestToken.deployed();
    let balance = await instance.balanceOf.call(accounts[0]);
    let totalSupply = await instance.totalSupply.call();
    assert.equal(balance.toNumber(), totalSupply.toNumber());
  });

  it("should transfer coins correctly", async () => {
    // Get initial balances of first and second account.
    let account_one = accounts[0];
    let account_two = accounts[1];

    let amount = 10;

    let tokenInstance = await TestToken.deployed();

    let balance = await tokenInstance.balanceOf.call(account_one);
    let account_one_starting_balance = balance.toNumber();

    balance = await tokenInstance.balanceOf.call(account_two);
    let account_two_starting_balance = balance.toNumber();
    await tokenInstance.transfer(account_two, amount, { from: account_one });

    balance = await tokenInstance.balanceOf.call(account_one);
    let account_one_ending_balance = balance.toNumber();

    balance = await tokenInstance.balanceOf.call(account_two);
    let account_two_ending_balance = balance.toNumber();

    assert.equal(
      account_one_ending_balance,
      account_one_starting_balance - amount,
      "Amount wasn't correctly taken from the sender"
    );
    assert.equal(
      account_two_ending_balance,
      account_two_starting_balance + amount,
      "Amount wasn't correctly sent to the receiver"
    );
  });
});