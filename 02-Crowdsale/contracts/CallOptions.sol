pragma solidity ^0.4.25;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
     }
}


contract callOption {
    
    using SafeMath for uint;
    
    address public owner;
    
    address public buyer;
    
    
    uint public beginDate;
    uint public expiryDate;
    uint public strikePrice;
    
    
    uint public premium;
    
    
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public totalSupply;
    
    address public tokenAddress;
 
    
    uint public quantity;
    
    
    mapping(address => uint) optionBalances;
    
   
   
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor(address _owner, 
    uint _beginDate, 
    uint _expiryDate, 
    uint _premium, 
    uint _quantity, 
    uint lockedDate, 
    uint _totalSupply) {
        owner = _owner;
        premium = _premium;
        beginDate = _beginDate;
        expiryDate = _expiryDate;
        quantity = _quantity;
        totalSupply = _totalSupply;
        
    }
    
    function Expired() returns(bool) {
        return expiryDate < now;
    }
    
    
   function transfer(address to, uint options) public returns (bool success) {
        require(!Expired());
        optionBalances[msg.sender] = optionBalances[msg.sender].sub(options);
        optionBalances[to] = optionBalances[to].add(options);
        return true;
    }
    
    function buy(uint premium, uint options) payable {
        require(msg.value == premium && !Expired());
        
        optionBalances[buyer] = optionBalances[buyer].add(options);
        optionBalances[owner] = optionBalances[owner].sub(options);
        
    } 
    
    function balanceOf(address optionsOwner) public constant returns (uint balance) {
        return optionBalances[optionsOwner];
    }
    
    function burn(uint _value) public {
        require(_value <= optionBalances[msg.sender]);
        address burner = msg.sender;
        optionBalances[burner] = optionBalances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
    }
    
    function exercise(uint _amount, uint _quantity) payable {
        require(msg.sender == buyer && !Expired());
        
        
        uint amount = strikePrice * _quantity;
        require(msg.value == amount && amount == _amount);
        
        owner.transfer(msg.value);
        
        burn(_quantity);
        
        
    }
    
    
    
    
}

contract optionsFactory {
    address[] public deployedOptions;

    function createCallOption(uint _beginDate, uint _expiryDate, uint _premium, uint _quantity, uint lockedDate, uint _totalSupply) public {
        address newOption = new callOption(msg.sender, _beginDate, _expiryDate, _premium, _quantity, lockedDate, _totalSupply);
        deployedOptions.push(newOption);
    }

    function getDeployedOptions() public view returns (address[]) {
        return deployedOptions;
    }
}