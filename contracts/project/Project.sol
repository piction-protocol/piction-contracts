pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IProject.sol";

contract Project is Ownable, IProject {
    
    string public url;
    string public title;
    uint256 public subscriptionPrice;

    constructor(
        string _url, 
        string _title, 
        uint256 _subscriptionPrice,
        address _owner
    )
        public
    {
        url = _url;
        title = _title;
        subscriptionPrice = _subscriptionPrice;

        transferOwnership(_owner);
    }

    function updateProject(string _title, uint256 _subscriptionPrice) external onlyOwner {
        title = _title;
        subscriptionPrice = _subscriptionPrice;

        emit UpdateProject(msg.sender, title, subscriptionPrice, now * 1000);
    }

    function changeSubscriptionPrice(uint256 _subscriptionPrice) external onlyOwner {
        subscriptionPrice = _subscriptionPrice;

        emit ChangeSubscriptionPrice(msg.sender, subscriptionPrice, now * 1000);
    }

    function getProjectOwner() external view returns(address) {
        return owner();
    }

    event UpdateProject(address indexed owner, string title, uint256 subscriptionPrice, uint256 timestamp);
    event ChangeSubscriptionPrice(address indexed owner, uint256 subscriptionPrice, uint256 timestamp);
}