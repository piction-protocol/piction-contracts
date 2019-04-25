pragma solidity ^0.4.24;

interface ISupportSaleManager {
    function createPicSale(string contentsHash, uint256 picPrice) external;
    function cancelPicSale(string contentsHash) external;
    function refundPic(string contentsHash) external;
    function withDrawPic(string contentsHash) external;
    function remainingBalance(string contentsHash) external view returns (uint256 picBalance, uint256 pxlBalance);
    function getPicPrice(string contentsHash) external view returns (uint256 picPrice);
    function getEndTime(string contentsHash) external view returns (uint256 endTime);
    function getSaleValue(string contentsHash) external view returns (uint256 picPrice, uint256 maxcap, uint256 endtime, uint256 pxlRaised);
}