pragma solidity ^0.5.2;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";

/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 * 
 * Cap should be 10000000000000000000000000 (100 Million)
 * Ropsten Toekn Address https://ropsten.etherscan.io/address/0x4eab3810a70f18c9c9bb79e7177283cb75948300
 */
 
 

contract BreathToken  is ERC20Capped, ERC20Detailed {
  //We inherited the DetailedERC20 
  constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _cap) 
      ERC20Detailed(_name, _symbol, _decimals)
      ERC20Capped(_cap)
    public {
        //nothing todo
        
    }
    
}
