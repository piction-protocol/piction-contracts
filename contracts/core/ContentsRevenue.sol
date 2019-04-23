pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsRevenue.sol";
import "../utils/ValidValue.sol";

contract ContentsRevenue is IContentsRevenue, ValidValue {
    using SafeMath for uint256;

    IPictionNetwork private pictionNetwork;

    uint256 constant DECIMALS = 10 ** 18;

    constructor(address pictionNetworkAddress) public validAddress(pictionNetworkAddress) {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
    }

    /**
     * @dev 전송된 PXL을 각 비율별로 계산
     * @param cdRate ContentsDistributor의 분배 비율
     * @param supporterPoolRate SupporterPool 분배 비율
     * @param contentsProvider Contents Provider 주소
     * @param amount 전송받은 PXL 수량
     */
    function calculateDistributionPxl(
        uint256 cdRate, 
        uint256 supporterPoolRate, 
        address contentsProvider, 
        uint256 amount
    )
        external 
        view
        // validRate(cdRate)
        // validRate(supporterPoolRate)
        // validAddress(contentsProvider)
        returns (address[] memory addresses, uint256[] memory amounts)
    {
        addresses = new address[](4);
        amounts = new uint256[](4);

        uint256 contentsDistributorAmount = amount.mul(cdRate).div(DECIMALS);

        uint256 userAdoptionPoolAmount = amount.mul(pictionNetwork.getRate("UserAdoptionPool")).div(DECIMALS);
        uint256 ecosystemFundAmount = amount.mul(pictionNetwork.getRate("EcosystemFund")).div(DECIMALS);
        uint256 supporterPoolAmount = amount.mul(supporterPoolRate).div(DECIMALS);
        uint256 contentsProviderAmount = amount.sub(contentsDistributorAmount).sub(userAdoptionPoolAmount).sub(ecosystemFundAmount).sub(supporterPoolAmount);

        addresses[0] = pictionNetwork.getAddress("UserAdoptionPool");
        amounts[0] = userAdoptionPoolAmount;
        
        addresses[1] = pictionNetwork.getAddress("EcosystemFund");
        amounts[1] = ecosystemFundAmount;

        addresses[2] = pictionNetwork.getAddress("SupporterPool");
        amounts[2] = supporterPoolAmount;

        addresses[3] = contentsProvider;
        amounts[3] = contentsProviderAmount;
    }
}