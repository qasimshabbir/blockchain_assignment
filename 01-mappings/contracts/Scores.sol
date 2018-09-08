pragma solidity 0.4.24;

contract Scores{
    
    //struct for User Profile
    struct User{
        string name;
        uint score;
    }
    
    //store Level Information
    struct Level{
        string title;
        uint minScore;
        uint maxScore;
    }
    
    //mapping for users against level
    mapping(string=>User[]) userLevels;
    
    //available levels
    Level[] levelInfo;
    
    
    constructor() public {
        //filling available level information
        
        levelInfo.push(Level("Level 1",1,99));
        levelInfo.push(Level("Level 2",100,199));
        levelInfo.push(Level("Level 3",200,999));
    }
    
    event logUser(string,uint);
    
    function addUser(string _name, uint _score) public validScore(_score) returns(string){
        int256 idx = getLevelIndex(_score);
        User memory user = User(_name,_score);
        string memory level = levelInfo[uint256(idx)].title;
        
        userLevels[level].push(user);
        return levelInfo[uint256(idx)].title;
    }
    
    function getUserByScore(string _level,uint _minScore) public view validLevel(_level,_minScore){
        
        //get Users
        User[] memory users = userLevels[_level]; 
        
        for(uint i=0; i<users.length; i++){
            if(users[i].score >= _minScore)
                emit logUser(users[i].name,users[i].score);
        }
        
    }
    
    
    function getLevelIndex(uint score) private view returns(int){
        for(uint i=0;i<levelInfo.length; i++){
            if(score > levelInfo[i].minScore && score < levelInfo[i].maxScore){
                return int(i);
            }
        }
        return -1;
    }
    
    modifier validScore(uint _score){
        uint256 minScore = levelInfo[0].minScore;
        uint256 maxScore = levelInfo[levelInfo.length-1].maxScore;
        require(_score > levelInfo[0].minScore && _score < maxScore,"Invalid Score" );
        _;
    }
    
    modifier validLevel(string _level, uint _score){
        bool isValidLevel = false;

        for(uint i=0;i<levelInfo.length; i++){
            if(
                    keccak256(levelInfo[i].title) == keccak256(_level) &&
                    (_score > levelInfo[0].minScore && _score < levelInfo[0].maxScore)
                ) 
            {
                isValidLevel = true;
                break;
            }
        }
        require(isValidLevel,"Invalid Level or Score not related to level");
        _;
    }
    
    
    
    
}