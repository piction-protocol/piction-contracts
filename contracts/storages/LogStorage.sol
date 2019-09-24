pragma solidity ^0.4.24;

import "../interfaces/IProxy.sol";
import "../utils/ExtendsOwnable.sol";


contract LogStorage is IProxy, ExtendsOwnable {


    event SignIn(address indexed user, string platform);
    event SignUp(address indexed user, string platform);
    event View(address indexed project, address indexed user, uint256 postId, string platform);
    event Subscription(address indexed project, address indexed user, uint256 price, string platform);
    event UnSubscription(address indexed project, address indexed user, string platform);
    event Like(address indexed project, address indexed user, uint256 postId, string platform);
    event Sponsorship(address indexed sponsor, address indexed creator, uint256 amount, string platform);
    event SearchTag(uint256 indexed tagId, address indexed user, string tag, string platform);
}