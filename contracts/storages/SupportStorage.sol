pragma solidity ^0.4.24;

import "./Storage.sol";
import "../interfaces/ISupportStorage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/ExtendsOwnable.sol";

contract SupportStorage is Storage, ISupportStorage, ExtendsOwnable {

    IPictionNetwork private pictionNetwork;

    struct Sale {
        uint256 price;
        uint256 maxCap;
        uint256 endTime;
        uint256 pxlRaised;
        mapping (address => uint256) pxlAmount;     // 구조체 밖으로 뺄경우 약간의 가스비용이 더 발생
    }

    mapping (string => Sale) private sales;

    constructor(address piction) public {
        require(piction != address(0), "SupportStorage constructor 0");

        pictionNetwork = IPictionNetwork(piction);
    }

    function setSaleValue(string key, uint256 price, uint256 maxCap, uint256 endTime, string tag) external onlyOwner {
        sales[key] = Sale(price, maxCap, endTime, 0);

        emit SetSaleValue(tag, key, price, maxCap, endTime);
    }
    
    function getSaleValue(string key) external view onlyOwner returns(uint256 price, uint256 maxCap, uint256 endTime, uint256 pxlRaised){
        return (sales[key].price, sales[key].maxCap, sales[key].endTime, sales[key].pxlRaised);
    }
    
    function setPxlRaised(string key, uint256 pxlRaised, string tag) external onlyOwner {
        sales[key].pxlRaised = pxlRaised;

        emit SetPxlRaised(tag, key, pxlRaised);
    }

    function getPxlRaised(string key) external view returns(uint256 pxlRaised) {
        return sales[key].pxlRaised;
    }
    
    function setPxlAmount(string key, address buyer, uint256 amount, string tag) external onlyOwner {
        sales[key].pxlAmount[buyer] = amount;

        emit SetPxlAmount(buyer, key, amount, tag);
    }

    function getPxlAmount(string key, address buyer) external view returns(uint256 pxlAmount) {
        return sales[key].pxlAmount[buyer];
    }
    event SetPxlAmount(address indexed buyer, string key, uint256 pxlAmount, string tag);

// Storage interface
    function setBooleanValue(string key, bool value, string tag) public onlyOwner {
        super.setBooleanValue(key, value, tag);
    }

    function setBytesValue(string key, bytes value, string tag) public onlyOwner {
        super.setBytesValue(key, value, tag);
    }

    function setStringValue(string key, string value, string tag) public onlyOwner {
        super.setStringValue(key, value, tag);
    }

    function setUintValue(string key, uint256 value, string tag) public onlyOwner {
        super.setUintValue(key, value, tag);
    }

    function setAddressValue(string key, address value, string tag) public onlyOwner  {
        super.setAddressValue(key, value, tag);
    }

    function getBooleanValue(string key) public onlyOwner view returns(bool value) {
        return super.getBooleanValue(key);
    }

    function getBytesValue(string key) public onlyOwner view returns(bytes value) {
        return super.getBytesValue(key);
    }

    function getStringValue(string key) public onlyOwner view returns(string value) {
        return super.getStringValue(key);
    }

    function getUintValue(string key) public onlyOwner view returns(uint256 value) {
        return super.getUintValue(key);
    }

    function getAddressValue(string key) public onlyOwner view returns(address value) {
        return super.getAddressValue(key);
    }

    function deleteBooleanValue(string key, string tag) public onlyOwner {
        super.deleteBooleanValue(key, tag);
    }

    function deleteBytesValue(string key, string tag) public onlyOwner  {
        super.deleteBytesValue(key, tag);
    }

    function deleteStringValue(string key, string tag) public onlyOwner {
        super.deleteStringValue(key, tag);
    }

    function deleteUintValue(string key, string tag) public onlyOwner {
        super.deleteUintValue(key, tag);
    }

    function deleteAddressValue(string key, string tag) public onlyOwner  {
        super.deleteAddressValue(key, tag);
    }
}