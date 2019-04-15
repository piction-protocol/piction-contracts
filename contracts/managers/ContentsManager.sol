pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/StringLib.sol";

contract ContentsManager is Ownable, ValidValue {

    string public constant STORAGE_NAME = "ContentsStorage";
    string public constant ACCOUNT_NAME = "AccountsManager";
    string public constant CREATE_TAG = "createContent";
    string public constant UPDATE_TAG = "updateContent";

    IPictionNetwork pictionNetwork;

    constructor(address piction) validAddress(piction) {
        pictionNetwork = IPictionNetwork(piction);
    }

    function createContent(string userHash, string contentHash, string rawData) 
        external
        validString(userHash) 
        validString(contentHash)
        validString(rawData)
    {
        //todo Call
        //IAccountManager accountManager = pictionNetwork.getAddress(ACCOUNT_NAME)
        //require(msg.sender == accountManager.getUserAddress(userHash), "createContent : Not Match Sender")

        //if Content Deploy

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        require(iStorage.getAddressValue(contentHash) == address(0) ,"createContent : Already address.")
        require(StringLib.isEmptyString(iStorage.getStringValue(contentHash)),"createContent : Already rawdata.")

        iStorage.setAddressValue(contentHash, msg.sender, CREATE_TAG);
        iStorage.setStringValue(contentHash, rawData, CREATE_TAG);
    }

    function updateContent(string userHash, string contentHash, string rawData) 
        external
        validString(userHash) 
        validString(contentHash)
        validString(rawData)
    {
        //todo Call
        //IAccountManager accountManager = pictionNetwork.getAddress(ACCOUNT_NAME)
        //require(msg.sender == accountManager.getUserAddress(userHash), "createContent : Not Match Sender")

        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));
        
        require(iStorage.getAddressValue(contentHash) == msg.sender ,"updateContent : Not Match User.");
        require(!StringLib.isEmptyString(iStorage.getStringValue(contentHash)),"updateContent : rawdata Empty");

        iStorage.setStringValue(contentHash, rawData, UPDATE_TAG);
    }

    function removeContent(){
        
    }
    
    function getWriter(string contentHash) external  returns(address writer) {
        IStorage iStorage = IStorage(pictionNetwork.getAddress(STORAGE_NAME));

        writer = iStorage.getAddressValue(contentHash);
        require(writer != address(0), "getWriter : Address 0");
    }

}