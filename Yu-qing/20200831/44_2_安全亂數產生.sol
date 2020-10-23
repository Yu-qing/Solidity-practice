//請使用 Rinkeby 測試網測試，不能用單機 VM 測試

pragma solidity ^0.4.11;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.sol";

contract RandomExample is usingOraclize {
    
    event newRandomNumber_bytes(bytes);
    event newRandomNumber_uint(uint);
    uint public new_random;

   constructor() payable public {
        oraclize_setProof(proofType_Ledger); // 在構造函數中設置Ledger真實性證明
        update(); //在合同創建時，我們立即要求N個隨機字節！
    }
    
     // 結果準備好後，Oraclize調用回調函數
     // oraclize_randomDS_proofVerify修飾符可防止無效證明執行此功能代碼：
     //證明有效性在鏈上完全驗證
    function __callback(bytes32 _queryId, string _result, bytes _proof)public
    { 
        // 如果我們成功達到這一點，就意味著附加的真實性證明已經過去了！
        if (msg.sender != oraclize_cbAddress()) revert();
        
        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
            // 證明驗證失敗了，我們需要在這裡採取任何行動嗎？ （取決於案例）
        } else {
            //證明驗證已通過
            //現在我們知道隨機數是安全生成的，讓我們使用它。
            
            emit newRandomNumber_bytes(bytes(_result)); //  这是结果随机数 (bytes)
            
            // 為了簡單起見，如果需要，還可以將隨機字節轉換為uint
            uint maxRange = 2**(8* 7);
            // 這是我們想要獲得的最高價。 它永遠不應該大於2 ^（8 * N），其中N是我們要求數據源返回的隨機字節數
            uint randomNumber = uint(keccak256(abi.encodePacked(_result))) % maxRange;
            // 這是在[0，maxRange]範圍內獲取uint的有效方法
            new_random = randomNumber;
            
            emit newRandomNumber_uint(randomNumber); // this is the resulting random number (uint)
        }
    }
    
    function update() payable public{ 
        uint N = 7; // 我們希望數據源返回的隨機字節數
        uint delay = 0; // 執行發生前等待的秒數
        uint callbackGas = 200000; // 我們希望Oraclize為回調函數設置的gas量
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // 此函數在內部生成正確的oraclize_query並返回其queryId
    }
    
}