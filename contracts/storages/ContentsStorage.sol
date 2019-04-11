pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IStorage.sol";
import "../interfaces/IContentsStorage.sol";
import "../utils/ValidValue.sol";

contract ContentsStorage is IContentsStorage, IStorage/* Storage 변경 */, Ownable, ValidValue {

    string public constant MANAGER_NAME = "ContentsManager";

    struct StringHash {
        string hashString;
    }

    mapping (address => StringHash[]) contents;
    mapping (string => StringHash[]) posts;

    function setContent(address writer, string contentHash, string rawData, string tag) /* 접근 제한 */ public {
        contents[writer].push(StringHash(contentHash));
        super.setStringValue(contentHash, rawData, tag);
        
        //todo event?
    }
    
    function isDuplicatedContent(address writer, string contentHash) public view returns (bool duplicated) {
        for(uint256 i = 0 ; i < contents[writer].length ; i++) {
            if(_stringCompare(contents[writer][i].hashString, contentHash)) {
                return true;
            }
        }
    }

    function setPost(string contentHash, string postHash, string rawData, string tag) /* 접근 제한 */ public {
        posts[contentHash].push(StringHash(postHash));
        super.setStringValue(postHash, rawData, tag);

        //todo event
    }

    function isDuplicatedPost(string contentHash, string postHash, string tag) public view returns (bool duplicated) {
        for(uint256 i = 0 ; i < posts[contentHash].length ; i++) {
            if(_stringCompare(posts[contentHash][i].hashString, postHash)) {
                return true;
            }
        }
    }

    //Super
    function setBooleanValue(string key, bool value, string tag) /* 접근 제한 */ public {
        //super.setBooleanValue(key, value, tag);
    }

    function setStringValue(string key, string value, string tag) /* 접근 제한 */ public {
        //super.setStringValue(key, value, tag);
    }

    function setUintValue(string key, uint256 value, string tag) /* 접근 제한 */ public {
        //super.setUintValue(key, value, tag);
    }

    function setAddressValue(string key, address value, string tag) /* 접근 제한 */ public {
        //super.setAddressValue(key, value, tag);
    }
    function setBytesValue(string key, bytes value, string tag) /* 접근 제한 */ public {
        //super.setBytesValue(key, value, tag);
    }


    /**
    * @dev 빈 문자열 확인 함수
    * @param value 확인하고자 하는 string value
    * @return isEmpty 빈 문자열 확인 결과
    */
    function _isEmptyString(string value) private returns (bool isEmpty) {
        return (bytes(value).length == 0);
    }


    function _stringCompare(string value1, string value2) private returns (bool) {
        return (keccak256(value1) == keccak256(value2));
    }
}