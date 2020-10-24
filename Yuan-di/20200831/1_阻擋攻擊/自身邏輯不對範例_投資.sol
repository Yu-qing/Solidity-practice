pragma solidity ^0.4.24;

contract DistributeTokens {
    address public owner; 
    address[] investors; 
    uint[] investorTokens; 

    constructor() public {
        owner = msg.sender;
    }

    //投資
    function invest() public payable {
        investors.push(msg.sender);  //push 就是把東西加進去陣列裡面
        investorTokens.push(msg.value / 100); 
    }

    //分配獎金
    function distribute() public {
        require(msg.sender == owner); // only owner
        
        for(uint i = 0; i < investors.length; i++) { 
            investors[i].transfer(investorTokens[i]);
        }
    }
}