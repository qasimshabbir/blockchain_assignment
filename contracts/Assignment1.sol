pragma solidity ^0.4.19;

contract Assignment1{
    struct Student{
        string name;
        int code;
        string class;
    }

    mapping(string => Student) students;

    
    //setting students with address and student details.

    function setStudent(string _idx,int code,string name,string class) public{
        Student memory newStudent = Student(name,code,class);
        students[_idx] = newStudent;
        
    }

    
    //getting specific student.
    function getStudent(string _idx) public view returns (int, string, string){
        //Student memory student = students[_idx];
        return (students[_idx].code,students[_idx].name,students[_idx].class);
    }

}