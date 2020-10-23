pragma solidity ^0.4.24;
contract class28{    
    address public owner;
    uint public integer_1;

    constructor() public {
        owner = msg.sender;
        integer_1 = 50;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
  
    modifier checkInt {
        require(msg.sender == owner);
        _;
        require(integer_1 <= 100);
    }
  
    modifier checkMoreThan30(uint y) {
        require(y > 30);
        _;
    }

    //檢查送交易者
    function Add_check_Sender(uint x)public onlyOwner{
        integer_1 += x;
    }

    //檢查送交易者和最後數字
    function Add_checkSender_And_Num(uint x)public checkInt{
        integer_1 += x;
    }

    //檢查參數
    function Add_check_Num_30(uint x)public checkMoreThan30(x){
        integer_1 += x;
    }
}