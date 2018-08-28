pragma solidity ^0.4.19;

contract Assignment2{
    struct Student{
        string name;
        int code;
        int score;
    }

    mapping(string => Student[]) class;

    
    //setting students with address and student details.

    function setStudent(string _classIdx,int _code,string _name,int _score) public{
        Student memory newStudent = Student(_name,_code,_score);
        class[_classIdx].push(newStudent);        
    }

    
    //getting specific student.
    function getStudent(string _classIdx,int _code) public view returns (int, string, int){
        Student[] memory students;
        students = class[_classIdx];
        for(uint idx = 0; idx < students.length; idx++){
            if(students[idx].code == _code){
                return (students[idx].code,students[idx].name,students[idx].score);
            }
        }
        return(0,"",0);        
    }
    //getting student with minimum score from any given class
    function getStudentByScore(string _classIdx, int _minScore) public view returns (int,string,int){
        for(uint i = 0; i<class[_classIdx].length;i++){
            if(_minScore >= class[_classIdx][i].score ){
                return (class[_classIdx][i].code, class[_classIdx][i].name, class[_classIdx][i].score);
            }
        }
        //return empty string
        return (0,"",0);
    }

    //getting count of student
    function getStudentCountInClass(string _classIdx) public view returns(uint){
        return class[_classIdx].length;
    }
    
    //removing specefic student from Class
    function removeStudent(string _classIdx,int _code) public returns (bool){
        
        for(uint idx = 0; idx < class[_classIdx].length; idx++){
            if(class[_classIdx][idx].code == _code){
                delete class[_classIdx][idx];
                return true;
            }
        }
        return false;
    }

    
    

}