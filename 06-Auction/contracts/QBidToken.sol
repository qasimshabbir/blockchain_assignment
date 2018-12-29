pragma solidity ^0.5.0;


import "./SafeMath.sol";
import "./Address.sol";
import "./QAuction.sol";

// interface of your Customize token ERC223
interface QBidInterface {
    
    uint256 internal _totalSupply;
    function balanceOf(address who) public view returns (uint);
  
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function decimals() external view returns (uint8 _decimals);
    function totalSupply() external view returns (uint256 _supply);

    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes memory data) public returns (bool ok);
    function transfer(address to, uint value, bytes memory data, string memory custom_fallback) public returns (bool ok);
  
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);

}

 /*
 * Contract that is working with ERC223 tokens 
 * Todo: Must be our auction Contract
 */
 
contract ContractReceiver {
    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    
    
    function tokenFallback(address _from, uint _value, bytes memory _data) public pure {
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);
      
      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */
    }
}
// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// Here is your token on Ropsten 
// https://ropsten.etherscan.io/tx/0xb382cc6ce26e9fdf63ac47196c70225e60fd67656f8c978e3f2be7cb16f3d7f9
// Here is your Token Address in Ropsten Network
// 0x5768370098aed063C86b4C3ECC5ccBC58F0EE022
// ----------------------------------------------------------------------------
contract QBidToken is QBidInterface {
    using SafeMath for uint256;
    using Address for address;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 internal _totalSupply;
    
    address owner;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    // functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
	
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "QBID";
        name = "Auction Bid Token";
        decimals = 18;
        owner = msg.sender;
        _totalSupply = 100000000 * 10**uint(decimals); //100 million
        balances[owner] = _totalSupply;
		emit Transfer(address(0),owner,_totalSupply);
    }

    

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }


    // ------------------------------------------------------------------------
    // The balanceOf() function provides the number of tokens held by a given address.
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // - Invoke the function tokenFallback (address, uint256, bytes) in _to, if _to is a contract.
    // ------------------------------------------------------------------------
    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes memory _data, string memory _custom_fallback) public returns (bool success) {
        if(_to.isContract()) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
    
    
    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes memory _data) public returns (bool success) {
      
        if(_to.isContract()) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
    
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    function transfer(address _to, uint _value) public returns (bool success) {
      
        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if(_to.isContract()) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }
    }
    

   
    //function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes memory _data) private returns (bool success) {
        if (balances[msg.sender] < _value) revert();
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
  
    //function that is called when transaction target is a contract
    //Since our fallback was Auction our fallback is Bid. 
    function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool success) {
        if (balances[msg.sender] < _value) revert();
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[msg.sender].add(_value);
        QAuction(_to).bid(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

 
    // ------------------------------------------------------------------------
    // Don't Accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }
    
}