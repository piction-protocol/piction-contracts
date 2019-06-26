pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/ValidValue.sol";

contract Airdrop is ValidValue {

    mapping (address => bool) private isReceivedUser;

    uint256 public constant airdropAmount = 1000 * (10 ** 18); //1000 * 1 ether;
    string private constant PXL = "PXL";

    IERC20 public iPxl;
    IPictionNetwork iPictionNetwork;

    constructor(address piction) public validAddress(piction) {
        iPictionNetwork = IPictionNetwork(piction);
        iPxl = IERC20(iPictionNetwork.getAddress(PXL));
    }

    function requestAirdrop() external {
        require(!isReceivedUser[msg.sender], "Airdrop requestAirdrop 0");

        iPxl.transfer(msg.sender, airdropAmount);
    }

    function balanceOf() external view returns(uint256) {
        return iPxl.balanceOf(address(this));
    }
}