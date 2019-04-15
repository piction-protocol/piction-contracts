pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";


contract PostManager is Ownable, ValidValue {

    string public constant STORAGE_NAME = "ContentsStorage";

    IPictionNetwork pictionNetwork;

    constructor(address piction) {
        pictionNetwork = IPictionNetwork(piction);
    }

    /**
     * @dev Post 생성 시 전달되는 RawData를 저장함
     * @param rawData Post 정보
     */
    function createPost(string contentHash, string postHash, string rawData) external {
        //인스턴스 생성
        IContentsStorage contentStorage = IContentsStorage(pictionNetwork.getAddress(STORAGE_NAME));
        
        //todo event??
    }

    function updatePost(){}

    function removePost(){}
}