pragma solidity ^0.4.25;
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.sol";

contract SimpleOraclizeContract is usingOraclize {

    string public BTCUSDT;
    
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);

    constructor()public payable {
       emit LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
    }

    function __callback(bytes32 myid, string result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        BTCUSDT = result;
        emit LogPriceUpdated(result);
    }

    //要有足夠的手續費給oraclize
    function updatePrice()public payable {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            oraclize_query("URL", "json(https://api.binance.com/api/v3/avgPrice?symbol=BTCUSDT).price");
        }
    }
}