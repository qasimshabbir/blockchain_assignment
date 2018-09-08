var Scores = artifacts.require("./Scores.sol");

module.exports = function(deployer) {
  deployer.deploy(Scores);
};
