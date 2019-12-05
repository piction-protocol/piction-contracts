pragma solidity ^0.4.24;

interface IWithdraw {
    function withdrawPXL() external;
    event WithdrawPXL(address indexed sender, uint256 value);
}