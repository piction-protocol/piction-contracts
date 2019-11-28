pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IEcosystemFund.sol";
import "../utils/ValidValue.sol";

contract EcosystemFund is Ownable, IEcosystemFund, ValidValue {
    string private constant PXL = "PXL";

    IERC20 public iPxl;
    IPictionNetwork private iPictionNetwork;
    
    constructor(address pictionNetwork) public validAddress(pictionNetwork) {
        iPictionNetwork = IPictionNetwork(pictionNetwork);
        iPxl = IERC20(iPictionNetwork.getAddress(PXL));
    }

    function withdrawPXL() external onlyOwner {
        uint256 amount = iPxl.balanceOf(address(this));
        iPxl.transfer(msg.sender, amount);

        emit WithdrawPXL(msg.sender, amount);
    }

    event WithdrawPXL(address indexed sender, uint256 value);
}
