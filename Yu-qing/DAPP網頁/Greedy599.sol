pragma solidity ^0.4.11;

import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.sol";     

library SafeMath {
 
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
 
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Greedy599 is usingOraclize {
    using SafeMath for uint;
    
    uint total_cost;                //所有人買鑰匙的總金額
    uint avg_price;
    uint initial_time;              //開始時間
    uint round_time;                //此回合時長
    uint airdrop_pool;              //空投池
    uint lottery_pool;              //彩金池
    uint total_key;
    address contract_owner;
    uint airdrop_random;                //空投亂數
    bool game = false;
    
    uint[2] public team_key;
    uint[] keyTeam;     //該鑰匙隊伍
    address[] keyOwner; //該鑰匙擁有者
    
    mapping (address => uint) prob;     //此玩家獲空投機率
    mapping (address => uint) key_own_num;  //此玩家擁有多少鑰匙
    mapping (address => uint) buy_price;     //最近一次鑰匙購買金額
    mapping (address => uint) do_classify;
    uint round = 0;
    uint win_money = 0;
    address win_person;
    event winner(uint round, address winner, uint money);
    
    uint air_win_money = 0;
    address air_win_person = 0;
    event airdrop_winner(address winner, uint money);
    
    constructor() payable public{
        require (msg.value >= 0.005 ether);  //用來支付gasfee 與 oraclize
        contract_owner = msg.sender;        //紀錄部署者
        oraclize_setProof(proofType_Ledger);
        update();
        play();
    }
    
    //開啟遊戲
    function play() public{
        require(msg.sender == contract_owner);
        initial_time = block.timestamp;
        game = true;
        round = round.add(1);
        
        //重置資料
        total_cost = 0;
        avg_price = 0.001 ether;         
        round_time = 599;
        
        for(uint i=0; i<total_key; i++){
            if(prob[keyOwner[i]] != 0){
                delete(prob[keyOwner[i]]);
            }
        }
        
        total_key = 0;
        team_key[0] = 0;
        team_key[1] = 0;
        delete keyTeam;   
        delete keyOwner; 
    }
    
    //購買鑰匙
    function buy_key(uint team) public payable{
        require(game == true);
        require(msg.value >= avg_price);
        require(team < 2);
        
        //更新秒數
        round_time = round_time.add(30);    //加30秒
        
        //紀錄金額
        buy_price[msg.sender] = msg.value;
        
        //更新變數
        total_cost = total_cost.add(msg.value);
        total_key = total_key + 1;
        avg_price = total_cost / total_key;
        avg_price = (avg_price / 10) * 11;   //  調漲10%
        
        team_key[team] = team_key[team] + 1;
        keyOwner.push(msg.sender);
        keyTeam.push(team);
        
        key_own_num[msg.sender] = key_own_num[msg.sender] + 1;
        
        do_classify[msg.sender] = 1;
        
        uint value = msg.value / 100;
        contract_owner.transfer(value * 5);
        airdrop_pool = airdrop_pool.add(value * 5);
        lottery_pool = lottery_pool.add(value * 55);
        
        //空投
        //增加機率
        if(prob[msg.sender] == 0){
            prob[msg.sender] = 5;
        }
        else{
            prob[msg.sender] = ((prob[msg.sender] / 5) * 5) + 5;
        }
    }
    
    //分配  遊戲方5% 空投池5% 分紅30% 獎金池 55%
    function distribute() public{
        require(do_classify[msg.sender] == 1);
        uint value = buy_price[msg.sender];
        uint team = keyTeam[key_own_num[msg.sender]-1];
        
        value = value / 100;
        value = (value*30) / (team_key[team] - 1);
        
        for(uint i=0; i<(total_key-1) ; i++){
            if(keyTeam[i] == team){
                keyOwner[i].transfer(value);
            }
        }
        
        do_classify[msg.sender] = 0;
    }
    
    //抽獎
    function airdrop() public{
        require(prob[msg.sender]%5 == 0);   //驗證是否重複抽獎
        msg.sender.transfer(0.0001 ether);
        
        if(airdrop_random <= prob[msg.sender]){
            
            uint value = buy_price[msg.sender];
            uint bonus = airdrop_pool.div(100);
            
            if(value <= 0.01 ether){
                bonus = bonus* 25;
            }
            else if(value <= 0.1 ether){
                bonus = bonus * 50;
            }
            else{
                bonus = bonus * 75;
            }
            
            msg.sender.transfer(bonus);
        
            airdrop_pool = airdrop_pool.sub(bonus);
            air_win_person = msg.sender;
            air_win_money = bonus;
            emit airdrop_winner(air_win_person, air_win_money);
            
            
            //將全部元素刪除
            for(uint i=0; i<total_key; i++){
                delete(prob[keyOwner[i]]);
            }
        }
        else{
            prob[msg.sender] = prob[msg.sender].add(1);
        }
        update();
    }
    
    
    //結束驗證與分配
    function time_proof()public{
        require(game == true);
        require(msg.sender == keyOwner[total_key-1]);
        
        if(tt() > round_time){
            
            uint money = lottery_pool / 100;
            uint bonus ;
            uint team = keyTeam[total_key-1];
            
            keyOwner[total_key-1].transfer(money * 48);
            contract_owner.transfer(money * 2);
            
            win_person = keyOwner[total_key-1];
            win_money = money * 48;
            
            emit winner(round, win_person, win_money);
            
            
            if(team == 0){
                bonus = (money * 40) / (team_key[team] - 1);
            }
            else{
                bonus = (money * 20) / (team_key[team] - 1);
            }
            
            lottery_pool = (lottery_pool / 2) - bonus;
        
            for(uint i=0; i<(total_key-1) ; i++){
                if(keyTeam[i] == team){
                    keyOwner[i].transfer(bonus);
                }
            }
            
            game = false;
            
        }
    }
    
    //池中金額
    function pool_Of_air() public view returns(uint){
        return airdrop_pool;
    }
    
    function pool_Of_lottery() public view returns(uint){
        return lottery_pool;
    }
    
    //剩餘時間
    function tt() public view returns(uint){
        return block.timestamp.sub(initial_time);
    }
    
    //一局多久
    function round_tt() public view returns(uint){
        return round_time;
    }
    //回合數
    function round_num() public view returns(uint){
        return round;
    }
    
    //合約者
    function contractOwner() public view returns(address){
        return contract_owner;
    }
    
    //開始時間
    function start_time()public view returns(uint){
        return initial_time;
    }
    
    //最後買家
    function last_buyer()public view returns(address){
        if(total_key == 0)
            return 0;
        return keyOwner[total_key-1];
    }
    
    //市價
    function market_price()public view returns(uint){
        return avg_price;
    }
    
    //鑰匙資料
    function key_of_owner() public view returns(uint[] key){
        require(game == true);
        uint[] memory mykey = new uint[](key_own_num[msg.sender]);
        uint count = 0;
        for(uint i = 0 ; i < total_key ;i++){
            if(keyOwner[i] == msg.sender){
                mykey[count] = i;
                count = count.add(1);
            }
        }
        return mykey;
    }
    function key_of_team(uint keyID) public view returns(uint team){
        require(game == true);
        
        return keyTeam[keyID];
    }
    
    //目前空投概率
    function airdrop_of_prob() public view returns(uint probability){
        require(game == true);
        return prob[msg.sender];
    }
    
    //贏家資料
    function winPerson() public view returns(address){
        return win_person;
    }
    function winMoney() public view returns(uint){
        return win_money;
    }
    
    //空投贏家資料
    function winAirPerson() public view returns(address){
        return air_win_person;
    }
    function winAirMoney() public view returns(uint){
        return air_win_money;
    }
    
    //遊戲是否開始
    function game_start() public view returns(bool){
        return game;
    }
    
    
    function __callback(bytes32 _queryId, string _result, bytes _proof)public
    {
        if (msg.sender != oraclize_cbAddress()) revert();
        
        if (oraclize_randomDS_proofVerify__returnCode(_queryId, _result, _proof) != 0) {
            //失敗，再做一次
            update();
        }
        else{
            //轉成1~100亂數
            airdrop_random = uint(keccak256(abi.encodePacked(_result))) % 100 + 1;
        }
    }
    
    function update() private{ 
        uint N = 7; // 我們希望數據源返回的隨機字節數
        uint delay = 0; // 執行發生前等待的秒數
        uint callbackGas = 200000; // 我們希望Oraclize為回調函數設置的gas量
        bytes32 queryId = oraclize_newRandomDSQuery(delay, N, callbackGas); // 此函數在內部生成正確的oraclize_query並返回其queryId
    }
    
    function kill() public{
        require(msg.sender == contract_owner);
        selfdestruct(msg.sender);
    }
}