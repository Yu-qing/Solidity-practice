pragma solidity ^0.4.24;
contract class27{
uint public integer_1 =1;

//require 會退回剩下gas
function require_example(uint x)public{
require(x <= 100,"x is bigger than 100");
integer_1 = x;
}

//revert 會退回剩下gas
function revert_example(uint x)public{
if(x > 100){
revert("x is bigger than 100");
}
integer_1 = x;
}

//assert 不退回gas 不常用 多用於不應該發生的嚴重錯誤 多用於結尾
function assert_example(uint x)public{
integer_1 = x;
assert(integer_1 <= 100);
}

uint public abc=0;
address public owner = 0x99B5dc30F27f8eEBe090Ae36e97aD00c082b37D1; //我的地址

function add_abc(uint x)public{
    abc++;
    assert(msg.sender == owner);
}

}