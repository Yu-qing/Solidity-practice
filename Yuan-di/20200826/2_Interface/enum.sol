pragma solidity ^0.4.24;

interface class37_Interface {
     function set(uint x)external;
     function get()external returns(uint);
}

contract class37 is class37_Interface{
    uint t = 0;
    
    function set(uint x)public{
        t = x;
    }

    function get()public view returns(uint){
        return t;
    }

    enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
    ActionChoices choice;

    function setGoStraight() public {
        choice = ActionChoices.GoStraight;
    }
    function getChoice() public view returns (ActionChoices) {
        return choice;
    }
}