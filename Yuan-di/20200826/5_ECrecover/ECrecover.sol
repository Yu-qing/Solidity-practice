pragma solidity ^0.4.4;

contract class40{
    //使用 https://www.myetherwallet.com/signmsg.html  
    //驗證數據
    function decode(string message, bytes signedString) public pure returns (address){
        bytes32  r = bytesToBytes32(slice(signedString, 0, 32));
        bytes32  s = bytesToBytes32(slice(signedString, 32, 32));
        byte  v = slice(signedString, 64, 1)[0];
        return ecrecoverDecode(message, r, s, v);
    }
  
    //使用ecrecover找到公鑰證明是由本人簽發
    function ecrecoverDecode(string message, bytes32 r, bytes32 s, byte v1) public pure returns (address addr){
        uint8 v = uint8(v1);
        bytes memory prefix = "\x19Ethereum Signed Message:\n5";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, message));
        addr = ecrecover(prefixedHash, v, r, s);
    } 

    //切割工具
    function slice(bytes memory data, uint start, uint len) internal pure returns (bytes){
        bytes memory b = new bytes(len);
            for(uint i = 0; i < len; i++){
            b[i] = data[i + start];
        }
    
        return b;
    }

    //bytes轉換bytes32
    function bytesToBytes32(bytes memory source) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
}