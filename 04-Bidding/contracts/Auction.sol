pragma solidity ^0.4.24;

contract Auction {
    struct Bid{
        address bidder;
        string name;
        uint256 bid;
    }
    uint256 highestBid;
    address highestBidder;

    Bid[] bids;
    event logBid(string name,uint256 value, address bidder);
    event logString(string _string);

    //bdding 
    function bid(string name, uint256 value) public returns(bool success) {
        require(value >= highestBid,"Bid must be greater than highest bid");
        
        bids.push(Bid(msg.sender,name,value));
        highestBid = value;
        highestBidder = msg.sender;
        emit logBid(name,value,msg.sender);
        success = true;
    }

    function getBids() public  returns(bytes32[]){
        require(highestBid > 0,"0 Bids avaialble");
        bytes32[] memory _mbids = new bytes32[];
        for(uint256 i; i<bids.length; i++){
            bytes32[] a = new bytes32[];
            a.push(bytes32(bids[i].name));
            a.push(",");
            a.push(bytes32(bids[i].bid));
            emit logString(string(a));
            _mbids.push(a);
         
        }
        return _mbids;
        
    }


}
