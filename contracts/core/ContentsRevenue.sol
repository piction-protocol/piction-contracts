pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IPictionNetwork.sol";

library ContentsRevenue {
    using SafeMath for uint256;

    /**
     * @dev PXL을 각 비율별로 전송
     * @param pictionNetworkAddress PictionNetwork 주소
     * @param distributionRate ContentsDistributor의 분배 비율
     * @param supporterPoolRate SupporterPool 분배 비율
     * @param contentsProvider 작가 주소
     * @param amount 토큰 권리 위임 수량
     */
    function transferDistributePxl(address pictionNetworkAddress, uint256 distributionRate, uint256 supporterPoolRate, address contentsProvider, uint256 amount) internal {
        // uint256 DECIMALS = 10 ** 18;

        IPictionNetwork pictionNetwork = IPictionNetwork(pictionNetworkAddress);
        IERC20 pxlToken = IERC20(pictionNetwork.getAddress("PXL"));
        
        uint256 contentsDistributorAmount = amount.mul(distributionRate).div(10 ** 18);
        uint256 userAdoptionPoolAmount = amount.mul(pictionNetwork.getRate("UserAdoptionPool")).div(10 ** 18);
        uint256 ecosystemFundAmount = amount.mul(pictionNetwork.getRate("EcosystemFund")).div(10 ** 18);
        uint256 supporterPoolAmount = amount.mul(supporterPoolRate).div(10 ** 18);

        uint256 contentsProviderAmount = amount.sub(contentsDistributorAmount).sub(userAdoptionPoolAmount).sub(ecosystemFundAmount).sub(supporterPoolAmount);

        if (userAdoptionPoolAmount > 0) {
            pxlToken.transfer(pictionNetwork.getAddress("UserAdoptionPool"), userAdoptionPoolAmount);
            emit Distribute(msg.sender, pictionNetwork.getAddress("UserAdoptionPool"), userAdoptionPoolAmount);
        }
        if (ecosystemFundAmount > 0) {
            pxlToken.transfer(pictionNetwork.getAddress("EcosystemFund"), ecosystemFundAmount);
            emit Distribute(msg.sender, pictionNetwork.getAddress("EcosystemFund"), ecosystemFundAmount);
        }
        if (supporterPoolAmount > 0) {
            pxlToken.transfer(pictionNetwork.getAddress("SupporterPool"), supporterPoolAmount);
            emit Distribute(msg.sender, pictionNetwork.getAddress("SupporterPool"), supporterPoolAmount);
        }
        if (contentsProviderAmount > 0) {
            pxlToken.transfer(contentsProvider, contentsProviderAmount);
            emit Distribute(msg.sender, contentsProvider, contentsProviderAmount);
        }
    }

    event Distribute(address indexed sender, address to, uint256 value);
}