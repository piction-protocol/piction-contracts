pragma solidity ^0.4.24;

interface IProject {
    function getProjectOwner() external view returns(address);
}
