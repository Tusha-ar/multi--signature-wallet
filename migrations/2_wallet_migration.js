const MultiSigWallet = artifacts.require("MultiSigWallet");

module.exports = function (deployer) {
  const owners = [
    "0xAfc74A3c54aa6a547B4242a3efF785Bd8c945f38",
    "0xd189327e17263f4B3CE1d423Db8e4A728A34b17F",
    "0xEe5EBBd193d7422E365A37Aa5E65FaCbe4410E4d",
  ];
  deployer.deploy(MultiSigWallet, owners, 2);
};
