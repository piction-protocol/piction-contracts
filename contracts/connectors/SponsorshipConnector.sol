pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

import "../tokens/ContractReceiver.sol";
import "../utils/ValidValue.sol";
import "../utils/BytesLib.sol";

contract SponsorshipConnector is Ownable, ContractReceiver, ValidValue {
    using BytesLib for bytes;

    mapping(address => bool) public contentProvider;
    
    IERC20 public iPxl;

    constructor(address pxl) public validAddress(pxl) {
        iPxl = IERC20(pxl);
    }

    function receiveApproval(address from, uint256 value, address token, bytes memory data) public {
        require(address(iPxl) == token, "SponsorshipConnector receiveApproval 0");
        require(value > 0, "SponsorshipConnector receiveApproval 1");

        address cp = data.toAddress(0);
        require(contentProvider[cp], "SponsorshipConnector receiveApproval 2");

        iPxl.transferFrom(from, cp, value);

        emit SponsorContentProvider(from, cp, value, now * 1000);
    }

    function putContentProvider(address cp) external onlyOwner validAddress(cp) {
        require(!contentProvider[cp], "SponsorshipConnector putContentProvider 0");
        
        contentProvider[cp] = true;
        emit RegisterContentProvider(cp);
    }

    function deleteContentProvider(address cp) external onlyOwner validAddress(cp) {
        require(contentProvider[cp], "SponsorshipConnector deleteContentProvider 0");
            
        contentProvider[cp] = false;
        emit DeleteContentProvider(cp);
    }

    function isPictionContentProvider(address cp) external view returns (bool isCP) {
        return contentProvider[cp];
    }

    function getPxlAddress() external view returns (address pxl) {
        return address(iPxl);
    }

    event RegisterContentProvider(address indexed cp);
    event DeleteContentProvider(address indexed cp);
    event SponsorContentProvider(address indexed from, address indexed to, uint256 value, uint256 blockTime);
}