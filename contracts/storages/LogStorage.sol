pragma solidity ^0.4.24;

import "../interfaces/IProxy.sol";
import "../interfaces/IProject.sol";
import "../utils/ExtendsOwnable.sol";


contract LogStorage is IProxy, ExtendsOwnable {

    function signIn(address user, string platform) external onlyOwner {
        emit SignIn(user, platform);
    }

    function signUp(address user, string platform) external onlyOwner {
        emit SignUp(user, platform);
    }

    function viewCount(address project, address user, uint256 postId, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage viewCount 0");

        emit View(project, user, postId, platform); 
    }

    function subscription(address project, address user, uint256 price, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage subscription 0");

        emit Subscription(project, user, price, platform); 
    }

    function unSubscription(address project, address user, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage unSubscription 0");

        emit UnSubscription(project, user, platform); 
    }

    function like(address project, address user, uint256 postId, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage like 0");

        emit Like(project, user, postId, platform); 
    }

    event SignIn(address indexed user, string platform);
    event SignUp(address indexed user, string platform);
    event View(address indexed project, address indexed user, uint256 postId, string platform);
    event Subscription(address indexed project, address indexed user, uint256 price, string platform);
    event UnSubscription(address indexed project, address indexed user, string platform);
    event Like(address indexed project, address indexed user, uint256 postId, string platform);
    event Sponsorship(address indexed sponsor, address indexed creator, uint256 amount, string platform);
    event SearchTag(uint256 indexed tagId, address indexed user, string tag, string platform);
}