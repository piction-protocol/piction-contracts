pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IUserAdoptionPool.sol";
import "../utils/ValidValue.sol";

contract UserAdoptionPool is Ownable, IUserAdoptionPool, ValidValue {

    string private constant PXL = "PXL";

    IERC20 public iPxl;
    IPictionNetwork private iPictionNetwork;
    
    constructor(address pictionNetwork) public validAddress(pictionNetwork) {
        iPictionNetwork = IPictionNetwork(pictionNetwork);
        iPxl = IERC20(iPictionNetwork.getAddress(PXL));
    }
    
    function refundPxl() external onlyOwner {
        uint256 amount = iPxl.balanceOf(address(this));

        iPxl.transfer(msg.sender, amount);
    }
}