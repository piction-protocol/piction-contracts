pragma solidity ^0.4.24;

interface ISupportStorage {
    function setPxlRaised(string key, uint256 pxlRaised, string tag) external;
    function setPxlAmount(string key, address buyer, uint256 amount, string tag) external;
    function setSaleValue(string key, uint256 price, uint256 maxCap, uint256 endTime, string tag) external;
    function getPxlRaised(string key) external view returns(uint256 pxlRaised);
    function getPxlAmount(string key, address buyer) external view returns(uint256 pxlAmount);
    function getSaleValue(string key) external view returns(uint256 price, uint256 maxCap, uint256 endTime, uint256 pxlRaised);

    event SetPxlRaised(string tag, string key, uint256 pxlRaised);
    event SetPxlAmount(address indexed buyer, string key, uint256 pxlAmount, string tag);
    event SetSaleValue(string tag, string key, uint256 price, uint256 maxCap, uint256 endTime);
}