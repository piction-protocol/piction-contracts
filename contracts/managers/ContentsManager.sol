pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/StringLib.sol";

contract ContentsManager is Ownable, ValidValue {

    string public constant STORAGE_NAME = "ContentsStorage";
    string public constant ACCOUNT_NAME = "AccountsManager";
    string public constant CREATE_TAG = "createContents";
    string public constant UPDATE_TAG = "updateContents";
    string public constant DELETE_TAG = "deleteContents";

    IPictionNetwork pictionNetwork;

    constructor(address piction) validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
    }

    /**
     * @dev 콘텐츠 생성 
     * @param userHash 생성하는 유저의 유일 값
     * @param contentsHash 생성하는 콘텐츠의 유일 값
     * @param rawData 생성되는 콘텐츠의 데이터
     */
    function createContents(string userHash, string contentsHash, string rawData) 
        external
        validString(userHash) 
        validString(contentsHash)
        validString(rawData)
    {
        //todo Call
        //IAccountManager accountManager = IAccountManager(pictionNetwork.getAddress(ACCOUNT_NAME));
        //require(msg.sender == accountManager.getUserAddress(userHash), "createContents : Not Match Sender");

        //if contents Deploy

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        require(iStorage.getAddressValue(contentsHash) == address(0) ,"createContents : Already address.")
        require(StringLib.isEmptyString(iStorage.getStringValue(contentsHash)),"createContents : Already rawdata.")

        iStorage.setAddressValue(contentsHash, msg.sender, CREATE_TAG);
        iStorage.setStringValue(contentsHash, rawData, CREATE_TAG);
    }

    /**
     * @dev 콘텐츠의 데이터를 업데이트
     * @param userHash 업데이트하는 유저의 고유 값
     * @param contentsHash 업데이트하는 콘텐츠의 고유 값
     * @param rawData 엡데이트 데이터
     */
    function updateContents(string userHash, string contentsHash, string rawData) 
        external
        validString(userHash) 
        validString(contentsHash)
        validString(rawData)
    {
        //todo Call
        //IAccountManager accountManager = IAccountManager(pictionNetwork.getAddress(ACCOUNT_NAME));
        //require(msg.sender == accountManager.getUserAddress(userHash), "updatecontents : Not Match Sender");

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        
        require(iStorage.getAddressValue(contentsHash) == msg.sender ,"updateContents : Not Match User.");
        require(!StringLib.isEmptyString(iStorage.getStringValue(contentsHash)),"updateContents : rawdata Empty");

        iStorage.setStringValue(contentsHash, rawData, UPDATE_TAG);
    }

    /**

     */
    function removeContents(string userHash, string contentsHash)
        external
        validString(userHash) 
        validString(contentsHash)
    {
        //todo Call
        //IAccountManager accountManager = IAccountManager(pictionNetwork.getAddress(ACCOUNT_NAME));
        //require(msg.sender == accountManager.getUserAddress(userHash) 
        //    || isOwner(msg.sender), "removeContents : Not Match Sender");

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        //require(iStorage.getAddressValue(contentsHash) == msg.sender
        //    || isOwner(msg.sender) ,"removeContents : Content Not Match User.");
        //require(!StringLib.isEmptyString(iStorage.getStringValue(contentsHash)),"updateContents : rawdata Empty");

        iStorage.deleteAddressValue(contentsHash, DELETE_TAG);
        iStorage.deleteStringValue(contentsHash, DELETE_TAG);

        emit RemoveContents(msg.sender, userHash, contentsHash);
    }
    
    /**
     * @dev 콘텐츠의 유저 주소를 반환
     * @param contentsHash 유저 주소를 조회하고자 하는 콘텐츠의 유일 값
     * @return writer 콘텐츠를 업로드한 유저의 주소
     */
    function getWriter(string contentsHash) 
        external  
        validString(contentsHash)
        returns(address writer) 
    {
        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        writer = iStorage.getAddressValue(contentsHash);
        require(writer != address(0), "getWriter : Address 0");
    }

}