pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsStorage.sol";
import "../utils/ValidValue.sol";
import "../utils/TimeLib.sol";


contract PostManager is Ownable, ValidValue {

    string public constant STORAGE_NAME = "ContentsStorage";

    address pictionNetwork;

    constructor(address piction) {
        pictionNetwork = piction;
    }

    /**
     * @dev Post 생성 시 전달되는 RawData를 저장함
     * @param rawData Post 정보
     */
    function createPost(string contentHash, string postHash, string rawData) external {
        //todo 접근제한

        //인스턴스 생성
        IContentsStorage contentStorage = IContentsStorage(IPictionNetwork(pictionNetwork).getAddress(STORAGE_NAME));

        //Content 있는지 확인
        require(contentStorage.isDuplicatedContent(msg.sender, contentHash), "createPost : Content Not Match.");

        //Post 중복 체크
        require(contentStorage.isDuplicatedPost(msg.sender, contentHash), "createPost : Post Duplicated.");
        
        contentStorage.setPost(contentHash, postHash, rawData, "createPost");
        
        //todo event??
    }

    function updatePost(){}

    function removePost(){}
}