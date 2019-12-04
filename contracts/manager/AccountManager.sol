pragma solidity ^0.4.24;

import "../utils/ValidValue.sol";
import "../utils/ExtendsOwnable.sol";
import "../utils/StringLib.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IAccountManager.sol";

/**
 * @title AccountManager
 * @dev Piction 계정 정보 관리
 */
contract AccountManager is ExtendsOwnable, ValidValue, IAccountManager {
    using StringLib for string;

    struct Account {
        bool isRegistered;
        string loginId;
        string email;
    }

    mapping (address => Account) accounts;

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
        createAccount(msg.sender, loginId, email);
        emit Signup(msg.sender, loginId, email);
    }

    /**
      * @dev 기존 가입 유저 migration - Piction 계정 실행
      * @param user 사용자 public address
      * @param loginId 사용자 login id
      * @param email 사용자 email 주소
      */
    function migration(address user, string loginId, string email) external onlyOwner validString(loginId) validString(email) {
        createAccount(user, loginId, email);
        emit Migration(msg.sender, user, loginId, email);
    }

    /**
      * @dev 유저 정보 수정
      * @param loginId 사용자 login id
      * @param email 사용자 email 주소
      */
    function updateAccount(string loginId, string email) external validString(loginId) validString(email) {
        require(accounts[msg.sender].isRegistered, "AccountManager updateAccount 0");
        require(accounts[msg.sender].loginId.compareString(loginId), "AccountManager updateAccount 1");

        accounts[msg.sender].email = email;
        emit UpdateAccount(msg.sender, email);
    }

    /**
      * @dev 유저 정보 삭제 - Piction 계정 실행
      * @param user 사용자 public address
      */
    function deleteAccount(address user) external onlyOwner {
        accounts[user].isRegistered = false;
        emit DeleteAccount(msg.sender, user);
    }

    /**
      * @dev 유저 생성 내부 함수
      * @param user 사용자 public address
      * @param loginId 사용자 login id
      * @param email 사용자 email 주소
      */
    function createAccount(address user, string loginId, string email) private {
        require(!accounts[user].isRegistered, "AccountManager createAccount 0");
        
        accounts[user].isRegistered = true;
        accounts[user].loginId = loginId;
        accounts[user].email = email;
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
      * @dev Piction에 가입 된 사용자 정보 확인
      * @param user 사용자 public address
      * @return 사용자 계정 정보
      */
    function getAccount(address user) external view returns (bool, string, string) {
        return (accounts[user].isRegistered, accounts[user].loginId, accounts[user].email);
    }

    event Signup(address indexed sender, string loginId, string email);
    event UpdateAccount(address indexed sender, string email);
    event DeleteAccount(address indexed sender, address indexed deleteUser);
    event Migration(address indexed sender, address indexed user, string loginId, string email);
}