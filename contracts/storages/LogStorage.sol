pragma solidity ^0.4.24;

import "../interfaces/IProxy.sol";
import "../interfaces/IProject.sol";


contract LogStorage is IProxy {

    function signIn(address user, string platform) external {
        emit SignIn(user, platform);
    }

    function signUp(address user, string platform) external {
        emit SignUp(user, platform);
    }

    function viewCount(address user, address project, uint256 postId, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage viewCount 0");

        emit View(project, user, postId, platform); 
    }

    function subscription(address user, address project, uint256 price, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage subscription 0");

        emit Subscription(project, user, price, platform); 
    }

    function unSubscription(address user, address project, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage unSubscription 0");

        emit UnSubscription(project, user, platform); 
    }

    function like(address user, address project, uint256 postId, string platform) external {
        require(IProject(project).getProjectOwner() != address(0), "LogStorage like 0");

        emit Like(project, user, postId, platform); 
    }

    function sponsorship(address user, address creator, uint256 amount, string platform) external {
        require(creator != address(0), "LogStorage sponsorship 0");

        emit Sponsorship(user, creator, amount, platform);
    }

    function tag(uint256 tagId, string tagName, string platform) external {
        require(tagId > 0, "LogStorage tag 0");
        require(bytes(tagName).length > 0, "LogStorage sponsorship 1");

        emit SearchTag(tagId, tagName, platform);
    }

    event SignIn(address indexed user, string platform);
    event SignUp(address indexed user, string platform);
    event View(address indexed project, address indexed user, uint256 postId, string platform);
    event Subscription(address indexed project, address indexed user, uint256 price, string platform);
    event UnSubscription(address indexed project, address indexed user, string platform);
    event Like(address indexed project, address indexed user, uint256 postId, string platform);
    event Sponsorship(address indexed sponsor, address indexed creator, uint256 amount, string platform);
    event SearchTag(uint256 indexed tagId, string tag, string platform);
}