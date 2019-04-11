pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";

contract ContentsManager is Ownable, ValidValue {

    string public constant STORAGE_NAME = "ContentsStorage";

    address pictionNetwork;

    constructor(address piction) validAddress(piction) {
        pictionNetwork = piction;
    }

    function createContent(string contentHash, string rawData) external {
        //msg.sender Account 유무 확인 필요

        //인스턴스 생성
        IContentsStorage contentStorage = IContentsStorage(IPictionNetwork(pictionNetwork).getAddress(STORAGE_NAME));
        //중복 체크
        require(contentStorage.isDuplicatedContent(msg.sender, contentHash)
        , "createContent : Content Duplicated.");

        contentStorage.setContent(msg.sender, contentHash, rawData, "createContent");

        //todo event?
    }

    

    function updateContent(){}
    

    function removeContent(){}
    
}