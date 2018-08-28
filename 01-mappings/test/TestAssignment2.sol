pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Assignment2.sol";

contract TestAssignment2{
    function fixture() public returns (Assignment2) {
        Assignment2 meta = new Assignment2();
        //Student of Class 1
        meta.setStudent("class1",1,"Qasim",10);
        meta.setStudent("class1",2,"Qasim1",20);
        meta.setStudent("class1",3,"Qasim2",0);
        meta.setStudent("class1",4,"Qasim3",80);

        //Student of Class 2
        meta.setStudent("class2",1,"Main",80);
        meta.setStudent("class2",2,"Main1",70);
        meta.setStudent("class2",3,"Main2",50);
        meta.setStudent("class2",4,"Main3",20);
        return meta;
    }
    function testSetStudent() public{
        Assignment2 meta = fixture();
        var (code,name,score) = meta.getStudent("class1",1);
        Assert.equal(name,"Qasim","Rerturns the correct value");
        Assert.equal(code,1,"Rerturns the correct value");
        Assert.equal(score,10,"Rerturns the correct value");
    }
    function testStudentCountInClass() public{
        Assignment2 meta = fixture();
        Assert.equal(meta.getStudentCountInClass("class1"),4,"class1 Count is Total 4");
        Assert.equal(meta.getStudentCountInClass("class2"),4,"class2 Count is Total 4");
    }
    function testRemoveStudentIfClassExist() public{
        Assignment2 meta = fixture();
        //Removing client. Removing of client has intersting affect.
        Assert.equal(meta.removeStudent("class1",1),true,"Removed class1 of 1 Successfully");
        //No difference in count
        Assert.equal(meta.getStudentCountInClass("class1"),4,"Count is 4.. no change");
        //but there is no value in struct it was reset
        var (code,name,score) = meta.getStudent("class1",1);
        Assert.equal(name,"","Reset the name");
        Assert.equal(code,0,"Reset code");
        Assert.equal(score,0,"Reset score");
        
    }
    function testRemoveStudentIfClassNotExist() public{
        Assignment2 meta = fixture();
        Assert.equal(meta.removeStudent("class4",1),false,"Unable to remove");
    }
    function testGetStudentByScore() public{
        Assignment2 meta = fixture();
        var (code,name,score) = meta.getStudentByScore("class1",10);
        Assert.equal(name,"Qasim","Rerturns the correct value");
        Assert.equal(code,1,"Rerturns the correct value");
        Assert.equal(score,10,"Rerturns the correct value");
    }

}