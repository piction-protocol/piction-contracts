pragma solidity ^0.4.24;

interface IProjectManager {
    function stringValidation(string str) external view returns(bool);
    function getProjectOwner(string hash) external view returns(address);
    function getProject(string hash) external view returns(bool, address, string);
}