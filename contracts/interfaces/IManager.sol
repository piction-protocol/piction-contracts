pragma solidity ^0.4.24;

interface IManager {
    
    function getProjectOwner(string hash) external view returns(address);

    function getProject(string hash) external view returns(bool, address, string);

    function getAccount(address user) external view returns(bool, string, string);
}