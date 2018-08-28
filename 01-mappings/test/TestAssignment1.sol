pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Assignment1.sol";

contract TestAssignment1{
    function testGetStudent() public{
        //Assignment1 meta = Assignment1(DeloyedAddresses.Assignment1());
        Assignment1 meta = new Assignment1();
        meta.setStudent("qasim",1,"Qasim","First");
        
        var (code,name,class) = meta.getStudent("qasim");
        //var abc = name;
        //var aa = "Qasim";
        Assert.equal(code,1,"Rerturns the correct value");
    
    }
}