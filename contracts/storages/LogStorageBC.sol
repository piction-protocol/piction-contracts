pragma solidity ^0.4.24;

import "../interfaces/IProxy.sol";
import "../interfaces/IProject.sol";

/**
 *  Battle Comics Log
 */
contract LogStorageBC is IProxy {

    function viewCount(address user, string uuid, string platform, uint256 webtoonId, uint256 episodeId) external {

        emit View(user, uuid, platform, webtoonId, episodeId); 
    }

    event View(address indexed user, string uuid, string platform, uint256 webtoonId, uint256 episodeId);
}