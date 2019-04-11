pragma solidity ^0.4.24;

library StringLib {
    /**
    * @dev 빈 문자열 확인 함수
    * @param value 확인하고자 하는 string value
    * @return isEmpty 빈 문자열 확인 결과
    */
    function isEmptyString(string value) external pure returns(bool isEmpty) {
        return (bytes(value).length == 0);
    }

    /**
    * @dev 문자열 비교 함수
    * @param value1 비교하고자 하는 문자열
    * @param value2 비교하고자 하는 문자열
    * @return isSameValue 동일 문자열 확인 결과
    */
    function compareString(string value1, string value2) external pure returns(bool isSameValue) {
        return (keccak256(value1) == keccak256(value2));
    }
}