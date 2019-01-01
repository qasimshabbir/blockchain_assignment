pragma solidity ^0.4.25;

import "./SafeMath.sol";
import "./Address.sol";
import "./QBidToken.sol";
// QBid Token receiver is part of QbidToken. Its an interface.
contract QAuction{
  QBidToken public token;
  using SafeMath for uint256;
  using Address for address;
  
  //QArticle article;
  uint256 public tokenId;

  address public seller;
  uint public endTime;
  address public  highestBidder;
  uint256 public highestBid;
  
  //state
  bool ended; // Set to true at the end, disallows any change.
  bool cancelled;
  //bool sellerWithdrawn;
  
  mapping(address => uint256) pendingReturns; // Allowed withdrawals of previous bids
  
  // Events that will be emitted on changes.
  event HighestBidIncreased(address bidder, uint256 amount);
  event AuctionEnded(address winner, uint256 amount);
  event LogBid(address bidder, uint bid, address highestBidder, uint256 highestBid);
  event AuctionCancelled();

  modifier onlyBefore(uint _time) 
  { 
    require(now < _time);
    _; 
  }
  modifier onlyAfter(uint _time) 
  { 
    require(now > _time); 
    _; 
  }

  modifier onlyOwner{
    require(msg.sender == seller, "Only Owner can perform this transaction");
    _;
  }

  modifier onlyBidder(address _from){
    require(_from != seller, "Owner can't perform this transaction");
    _;
  }

  modifier onlyActive{
    require(!ended && !cancelled,"Auction is not active");
    _;
  }
  /**
    * @notice Constructor for contract. Sets token and beneficiary addresses.
    * @param _token token address - supposed to be QBID address
    * @param _seller recipient of received QBID Token
    * @param _tokenId token id is identifier of item can be replaced with NFT or IPFS link. 
    * @param _biddingTime Bidding time - duration of Auciton
    * @param _bidIncrement Initial bid or minimum price.
    */
  constructor(
      address _token,
      uint256 _tokenId, 
       
      uint _biddingTime, 
      uint _bidIncrement,
      address _seller
    ) 
    public 
  {
    //_auction.article = QArticle(_nftArticle);
    token = QBidToken(QbidTokenAddress);
    tokenId = _tokenId;
    seller = _seller;
    endTime = block.timestamp + _biddingTime;
    highestBid = _bidIncrement;
    highestBidder = 0;
    ended = false;
    cancelled = false;
  }

  //bid is a fallback method of QBidToken
  function bid(address _from, uint256 _value, bytes _data) 
    public
    onlyActive
    onlyBidder(_from)
    returns(bool success)
  {
    require(_value > 0,"Zero bid is not allowed");
    require(!_from.isContract(),"Invalid Address");
    
    //success = false;
    // calculate the user's total bid based on the current amount they've sent to the contract
    // plus whatever has been sent with this transaction
    uint256 newBid = pendingReturns[_from].add(_value);
    // if the user isn't even willing to overbid the highest binding bid, there's nothing for us
    // to do except revert the transaction.
    require(newBid > highestBid, "New Bid must be higher than last highest bid");
    emit LogBid(_from, _value, highestBidder, highestBid);
    if (highestBid != 0) {
      // Sending back the money by simply using
      // highestBidder.send(highestBid) is a security risk
      // because it could execute an untrusted contract.
      // It is always safer to let the recipients
      // withdraw their money themselves.
      pendingReturns[highestBidder] += highestBid;
    }
    highestBidder = _from;
    highestBid = newBid;
    emit HighestBidIncreased(_from, _value);
    success = true;
  }
  
  // Withdraw a bid that was overbid.
  function withdraw() public returns (bool) {
    uint amount = pendingReturns[msg.sender];
    if (amount > 0) {
      // It is important to set this to zero because the recipient
      // can call this function again as part of the receiving call
      // before `send` returns.
      pendingReturns[msg.sender] = 0;
      if (!token.transfer(msg.sender,amount)) {
        // No need to call throw here, just reset the amount owing
        pendingReturns[msg.sender] = amount;
        return false;
      }
    }
    return true;
  }
  /// End the auction and send the highest bid
  /// to the beneficiary.
  function auctionEnd() public {
      // It is a good guideline to structure functions that interact
      // with other contracts (i.e. they call functions or send Ether)
      // into three phases:
      // 1. checking conditions
      // 2. performing actions (potentially changing conditions)
      // 3. interacting with other contracts
      // If these phases are mixed up, the other contract could call
      // back into the current contract and modify the state or cause
      // effects (ether payout) to be performed multiple times.
      // If functions called internally include interaction with external
      // contracts, they also have to be considered interaction with
      // external contracts.

      // 1. Conditions
      require(block.timestamp >= endTime, "Auction not yet ended.");
      require(!ended, "auctionEnd has already been called.");

      // 2. Effects
      ended = true;
      emit AuctionEnded(highestBidder, highestBid);

      // 3. Interaction
      token.transfer(seller,highestBid);
  }

  function cancelAuction()
    public
    onlyOwner
    onlyActive
    returns (bool success)
  {
      cancelled = true;
      emit AuctionCancelled();
      return true;
  }

  /**
  * Convert bytes to uint
  * @param _data bytes Byte array
  * @param _offset uint256 Position to convert 
  * @param _length uint256 Data length
  */
  function toUint(bytes memory _data, uint256 _offset, uint256 _length)
  internal pure
  returns(uint256 _result) 
  {
      require(_offset >= 0);
      require(_length > 0);
      require((_offset + _length) <= _data.length);
      uint256 _segment = _offset + _length;
      uint256 count = 0;
      for (uint256 i = _segment; i > _offset ; i--) {
          _result |= uint256(_data[i-1]) << ((count++)*8);
      }
  }
}

contract QAuctions{
  address[] public lstAuctions;
  event AuctionCreated(address auctionContract, address seller, uint auctions, address[] allAuctions);

  /*
  function createAuction(
      uint bidIncrement, 
      uint256 startTime, 
      uint256 endTime, 
      address nftArticle
    )
    public
  { 
    QArticle _nftArticle = QArticle(nftArticle);
    QAuction auction =  new QAuction(msg.sender, bidIncrement, startTime,endTime, QArticle(nftArticle));
    auctions.push(auction);
    
    emit AuctionCeated(
        auction,
        msg.sender,
        auctions.length,
        auctions
    );
  }
  */
  /*
    * @param _token token address - supposed to be QBID address
    * @param _seller recipient of received QBID Token
    * @param _tokenId token id is identifier of item can be replaced with NFT or IPFS link. 
    * @param _biddingTime Bidding time - duration of Auciton
    * @param _bidIncrement Initial bid or minimum price.
    */
  function createAuction(
      address token,
      uint256 tokenId,
      uint256 bidIncrement, 
      uint256 biddingTime 
    )
    public
  { 
    //QArticle _nftArticle = QArticle(nftArticle);
    QAuction auction = new QAuction(token,tokenId, biddingTime, bidIncrement, msg.sender);
    lstAuctions.push(auction);
    
    emit AuctionCreated(
        auction,
        msg.sender,
        lstAuctions.length,
        lstAuctions
    );
  }
}