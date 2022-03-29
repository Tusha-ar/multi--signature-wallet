const MultiSigWallet = artifacts.require("MultiSigWallet");

contract("MultiSigWallet", async (address) => {
  let multiSigWallet;
  before(async () => {
    multiSigWallet = await MultiSigWallet.deployed();
  });

  it("should deposite eth properly", async () => {
    await multiSigWallet.deposite({
      value: "3000000000000000000",
    });
  });

  it("should create a transaction", async () => {
    await multiSigWallet.createTransaction(
      1,
      "0x7e9cC1B7AC3F97DA954B1C4dE8C669B6E59a71FC"
    );
    const transaction = await multiSigWallet.transactions(0);
    assert.equal(transaction.executed, false);
  });

  it("should not approve transaction before it have atleast minimum confirmations", async () => {
    let error = null;
    try {
      await multiSigWallet.approveTransaction(0);
    } catch (err) {
      error = err.data[`${Object.keys(err.data)[0]}`].reason;
    }
    assert.equal(error, "This txn is not confirmed by enough owners yet");
  });

  it("should not confirm transaction from a non-owner", async () => {
    let error = null;
    try {
      await multiSigWallet.confirmTransaction(0, { from: address[4] });
    } catch (err) {
      error = err.data[`${Object.keys(err.data)[0]}`].reason;
    }
    assert.equal(error, "Only owner can do this action");
  });

  it("should confirm the transaction properly", async () => {
    await multiSigWallet.confirmTransaction(0);
    await multiSigWallet.confirmTransaction(0, { from: address[1] });
    const txn = await multiSigWallet.transactions(0);
    assert.equal(txn.confirmations.toString(), "2");
  });

  it("should approve transaction on minimum confirmations", async () => {
    await multiSigWallet.approveTransaction(0);
    const txn = await multiSigWallet.transactions(0);
    assert.equal(txn.executed, true);
  });
});
