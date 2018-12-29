pragma solidity ^0.4.24;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721MetadataMintable.sol";

/**
 * @title Hear Token Token
 * Symbol HCO
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract HeartToken is ERC721MetadataMintable, ERC721Pausable, ERC721Enumerable, ERC721Burnable {
    uint256 internal _totalSupply;
    Roles.Role internal _CEO;
    Roles.Role internal _CFO;
    
    constructor (string name, string symbol,address _CFO, uint256 _totalSupply) ERC721Metadata(name, symbol)
      
        public 
    {
        //todo
        //It will assign owner to get approve all right.
        //Make owner the CEO, It will also take the company CFO
        //comapny CFO can pause
        this._CFO.add(_CFO);
        this._CEO.add(msg.sender);
        setApprovalForAll(this._CEO, true);
        //cfo can pause un pause.. Add CFO as pauser
        addPauser(this._CFO);
    }
    //meta data format
    /* tokeUri = "
    {
        "operation_type":1,
        "date":"2014-01-01T23:28:56.782Z",
        "geo":"100000.1:100000.1",
        "cause":"AAA",
        "SDG":1,
        "URL":"http://www.q-sols.com",
        "values":{
            0:1,
            1:2,
            3:4,
            4:5,
            6:2
        }
    }"
    */

}