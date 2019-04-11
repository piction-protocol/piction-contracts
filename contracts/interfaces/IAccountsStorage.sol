pragma solidity ^0.4.24;

import "./IStorage.sol";

contract IAccountsStorage is IStorage {
    function setAddressRegistration(address sender, string hash) external;
    function getAddressRegistration(address sender) external view returns(string hash);
}