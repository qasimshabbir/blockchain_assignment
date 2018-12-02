pragma soldity 0.4.25;
/*-------ERC721 Interface-----------*/
interface IERC721 {
   // ERC20 compatible functions
   function name() constant returns (string name);
   function symbol() constant returns (string symbol);
   function totalSupply() constant returns (uint256 totalSupply);
   function balanceOf(address _owner) constant returns (uint balance);
   // Functions that define ownership
   function ownerOf(uint256 _tokenId) constant returns (address owner);
   function approve(address _to, uint256 _tokenId);
   function takeOwnership(uint256 _tokenId);
   function transfer(address _to, uint256 _tokenId);
   function tokenOfOwnerByIndex(address _owner, uint256 _index) constant returns (uint tokenId);
   // Token metadata
   function tokenMetadata(uint256 _tokenId) constant returns (string infoUrl);
   // Events
   event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
   event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
}

import "./SafeMath.sol";
import "./Address.sol";
contract WitCallOptions is IERC721{
    using SafeMath for uint256;
    //address utility for checking whether address is EOA or Contract
    using Address for address;

    address public owner;
    
    address public buyer;
    
    
    uint public beginDate;
    uint public expiryDate;
    uint public strikePrice;
    
    
    uint public premium;
    

    string constant private tokenName= "WitCallOption";
    string constant private tokenSymbol = "WCO";
    uint256 constant private totalToken;
    

    //No. Of tokens each account Hold
    mapping(address => uint) private balances;
    //Owner of token
    mapping(uint256 => address) private tokenOwners;
    //Quick check for token exist or not
    mapping(uint256 => bool) private tokenExists;
    //Approves or Grant permission of token transfer
    mapping(address => mapping (address => uint256)) private allowed;
    //For transfer to check wether owner owned transfered tokens? 
    mapping(address => mapping(uint256 => uint256)) private ownerTokens;
    //Token links for external specification
    mapping(uint256 => string) tokenLinks;

    constructor(address _owner, 
        uint _beginDate, 
        uint _expiryDate, 
        uint _premium, 
        uint lockedDate, 
        uint _totalSupply
    ) {
        owner = _owner;
        premium = _premium;
        beginDate = _beginDate;
        expiryDate = _expiryDate;
        totalToken = _totalSupply;
    }
    

    function removeFromTokenList(address owner, uint256 _tokenId) private {
        for(uint256 i = 0;ownerTokens[owner][i] != _tokenId;i++){
            ownerTokens[owner][i] = 0;
        }
    }
   
    function name() public view returns (string){
       return tokenName;
    }
    
    function symbol() public view returns (string) {
       return tokenSymbol;
    }
    
    function totalSupply() public view returns (uint256){
       return totalToken;
    }
   
    function balanceOf(address _owner) public view returns (uint){
        require(owner != address(0));
        return balances[_owner];
    }
    //Get the owner of specified token
    function ownerOf(uint256 _tokenId) public view returns (address owner){
       require(tokenExists[_tokenId]);

       owner = tokenOwners[_tokenId]; 
    }
    
    function approve(address _to, uint256 _tokenId) public{
       require(msg.sender == ownerOf(_tokenId));
       require(msg.sender != _to);
       allowed[msg.sender][_to] = _tokenId;
       emit Approval(msg.sender, _to, _tokenId);
    }
   
    function takeOwnership(uint256 _tokenId) public{
       require(tokenExists[_tokenId]);
       
       address oldOwner = ownerOf(_tokenId);
       address newOwner = msg.sender;
       require(newOwner != oldOwner);
       require(allowed[oldOwner][newOwner] == _tokenId);
       balances[oldOwner] = balances[oldOwner].sub(1);
       tokenOwners[_tokenId] = newOwner;
       balances[newOwner] = balances[nweOwner].add(1);
       emit Transfer(oldOwner, newOwner, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public{
       address currentOwner = msg.sender;
       address newOwner = _to;
       require(tokenExists[_tokenId]);
       require(currentOwner == ownerOf(_tokenId));
       require(currentOwner != newOwner);
       require(newOwner != address(0));
       removeFromTokenList(_tokenId);
       balances[currentOwner] = balances[currentOwner].sub(1);
       tokenOwners[_tokenId] = newOwner;
       balances[newOwner] = balances[newOwner].add(1);
       emit Transfer(currentOwner, newOwner, _tokenId);
    }
   
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint tokenId){
       return ownerTokens[_owner][_index];
    }
    
    function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl){
       return tokenLinks[_tokenId];
    }

    //call option sepecific methods
    function Expired() returns(bool) {
        return expiryDate < now;
    }

    function buy(uint premium, uint options, address owner) external {
        require(msg.value == premium && !Expired());
        
        
    }
    function burn(uint _value) public {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalToken = totalToken.sub(_value);
    }
    
    function exercise(uint _amount, uint _quantity) external {
        require(msg.sender != address(0));
        require(msg.sender == buyer && !Expired());
                
        
        uint amount = strikePrice.mul(_quantity);
        require(msg.value == amount && amount == _amount);
        
        owner.transfer(msg.value);
        
        burn(_quantity);
        
        
    }
  
}
