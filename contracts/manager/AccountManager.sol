pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "../utils/ExtendsOwnable.sol";
import "../interfaces/IPictionNetwork.sol";

/**
 * @title AccountManager
 * @dev Piction 계정 정보 관리
 */
contract AccountManager is ExtendsOwnable, ValidValue {

    struct account {
        bool isRegistered;
        string loginId;
        string email;
    }

    mapping (address => account) accounts;
    mapping (string => bool) isDuplicateString;

    IPictionNetwork private pictionNetwork;

    constructor(address pictionNetworkAddress) public validAddress(pictionNetworkAddress) {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
    }

    /**
      * @dev Piction 회원 가입
      * @param loginId 사용자 login id
      * @param email 사용자 email 주소
      */
    function signup(string loginId, string email) external validString(loginId)  validString(email) {
        require(!accounts[msg.sender].isRegistered, "AccountManager signup 0");
        require(!isDuplicateString[loginId], "AccountManager signup 1");
        require(!isDuplicateString[email], "AccountManager signup 2");
        
        accounts[msg.sender].isRegistered = true;
        accounts[msg.sender].loginId = loginId;
        accounts[msg.sender].email = email;

        isDuplicateString[loginId] = true;
        isDuplicateString[email] = true;

        emit Signup(msg.sender, loginId, email);
    }

    /**
      * @dev 기존 가입 유저 migration - Piction 계정 실행
      * @param user 사용자 public address
      * @param loginId 사용자 login id
      * @param email 사용자 email 주소
      */
    function migration(address user, string loginId, string email) external onlyOwner validString(loginId) validString(email) {
        require(!accounts[user].isRegistered, "AccountManager migration 0");
        require(!isDuplicateString[loginId], "AccountManager migration 1");
        require(!isDuplicateString[email], "AccountManager migration 2");

        accounts[user].isRegistered = true;
        accounts[user].loginId = loginId;
        accounts[user].email = email;

        isDuplicateString[loginId] = true;
        isDuplicateString[email] = true;

        emit Migration(msg.sender, user, loginId, email);
    }

    /**
      * @dev Piction에 가입한 유저 확인
      * @param user 사용자 public address
      * @return 사용자 가입 유무
      */
    function accountValidation(address user) external view returns (bool) {
        return accounts[user].isRegistered;
    }

    /**
      * @dev Piction에 가입한 정보 확인
      * @param str 사용자 login id 또는 email 주소
      * @return 사용자 고유 정보 중복 여부
      */
    function stringValidation(string str) external view returns (bool) {
        return isDuplicateString[str];
    }

    /**
      * @dev Piction에 가입 된 사용자 정보 확인
      * @param user 사용자 public address
      * @return 사용자 계정 정보
      */
    function getAccount(address user) external view returns (bool, string, string) {
        return (accounts[user].isRegistered, accounts[user].loginId, accounts[user].email);
    }

    event Signup(address indexed sender, string loginId, string email);
    event Migration(address indexed sender, address indexed user, string loginId, string email);
}