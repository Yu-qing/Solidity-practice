pragma solidity ^0.4.24;

contract class36{
    uint internal a = 1;
    
    function external_example(uint x) external {
        a=x;
    }
    
    function internal_example(uint x) internal {
        a=x;
    }
    
    function public_example(uint x) public {
        a=x;
        internal_example(4);
    }
    
    function private_example(uint x) private {
        a=x;
    }
    
    function getA() public view returns(uint){
        return a;
    }
    
    function test(uint x) public{
        this.internal_example(x);
    }
}


contract class36_2 is class36{
    function call_internal2(uint x)public{
        private_example(x);
    }
}

 external_example(x);
        private_example(x);
        
     function call_private2(uint x)public{
         private_example(x);
     }
        