pragma solidity ^0.5.2;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";



contract GenTech is ERC20{
  using SafeMath for uint256;
  
  OracleInterface oracle;
  string public constant symbol = "Gtech";
  string public constant name = "GenTech";
  uint8 public constant decimals = 18;
  uint256 internal _reserveOwnerSupply;
  address owner;
  
  
  constructor(address oracleAddress) public {
    oracle = OracleInterface(oracleAddress);
    _reserveOwnerSupply = 300000000 * 10**uint(decimals); //300 million
    owner = msg.sender;
    _mint(owner,_reserveOwnerSupply);
  }

  function donate() public payable {}

  function flush() public payable {
    //amount in cents
    uint256 amount = msg.value.mul(oracle.price());
    uint256 finalAmount= amount.div(1 ether);
    _mint(msg.sender,finalAmount* 10**uint(decimals));
  }

  function getPrice() public view returns (uint256) {
    return oracle.price();
  }

  function withdraw(uint256 amountCent) public returns (uint256 amountWei){
    require(amountCent <= balanceOf(msg.sender));
    amountWei = (amountCent.mul(1 ether)).div(oracle.price());

    // If we don't have enough Ether in the contract to pay out the full amount
    // pay an amount proportinal to what we have left.
    // this way user's net worth will never drop at a rate quicker than
    // the collateral itself.

    // For Example:
    // A user deposits 1 Ether when the price of Ether is $300
    // the price then falls to $150.
    // If we have enough Ether in the contract we cover ther losses
    // and pay them back 2 ether (the same amount in USD).
    // if we don't have enough money to pay them back we pay out
    // proportonailly to what we have left. In this case they'd
    // get back their original deposit of 1 Ether.
    if(balanceOf(msg.sender) <= amountWei) {
      amountWei = amountWei.mul(balanceOf(msg.sender));
      amountWei = amountWei.mul(oracle.price());
      amountWei = amountWei.div(1 ether);
      amountWei = amountWei.mul(totalSupply());
    }
    _burn(msg.sender,amountCent);
    msg.sender.transfer(amountWei);
  }
}

interface OracleInterface {

  function price() external view returns (uint256);

}
contract MockOracle is OracleInterface {

    uint256 public price_;
    address owner;
    
    // functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
         _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    function setPrice(uint256 price) public onlyOwner {
    
      price_ = price;

    }

    function price() public view returns (uint256){

      return price_;

    }

}