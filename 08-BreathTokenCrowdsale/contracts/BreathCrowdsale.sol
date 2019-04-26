pragma solidity ^0.5.2;

import './BreathToken.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol';
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";

// 0xf203e6ed4a49956c26f325d13a8aa401f4b8654f
contract BreathTokenCrowdsale is Crowdsale, MintedCrowdsale, CappedCrowdsale {
    uint256 public investorMinCap = 2000000000000000000; //2 ether in wei
    uint256 public investorHardCap = 50000000000000000000; //50 ether in wei
    mapping(address => uint256) public contributions;
    
	/*
	 *@wallet //Your wallet id
	 *@token //Token address on ropsten 0xf203e6ed4a49956c26f325d13a8aa401f4b8654f 
	 *@cap //100 million
	 */
    constructor(uint256 _rate,
	  address payable _wallet, 
	  ERC20 _token, 
	  uint256 _cap)
	Crowdsale(_rate, _wallet, _token)
	CappedCrowdsale(_cap)
	public{
	    //nothing to implement since all business logic written 
	    //top contract
	}


  function _preValidatePurchase(address _beneficiary,uint256 _weiAmount ) internal view {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint256 _existingContribution = contributions[_beneficiary];
    uint256 _newContribution = _existingContribution.add(_weiAmount);
    require(_newContribution >= investorMinCap && _newContribution <= investorHardCap);
    
	
  }
  
   function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        super._processPurchase(beneficiary,tokenAmount);
        contributions[beneficiary] = contributions[beneficiary].add(tokenAmount);     
    }

}