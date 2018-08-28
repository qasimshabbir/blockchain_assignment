var token = artifacts.require("./QSolsToken.sol");

module.exports = function(deployer) {
  deployer.deploy(token);
};
