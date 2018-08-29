var AxiomDevCrowdsale = artifacts.require("./AxiomDevCrowdSale.sol");

module.exports = function(deployer) {
  //setup duration of ICO
  const startTime = Math.round((new Date(Date.now() - 86400000).getTime())/1000); // Yesterday
  const endTime = Math.round((new Date().getTime() + (86400000 * 20))/1000); // Today + 20 days
  deployer.deploy(
    AxiomDevCrowdsale,
    startTime,
    endTime,
    50,
    "0x9CdD9cb86Ff03aeCF9EA146d51af02526aa320ec", //Replace this wallet address with the last one (10th account) from Ganache UI. This will be treated as the beneficiary address.
    2000000000000000000, // 2 ETH
    500000000000000000000 // 500 ETH
  );
};
