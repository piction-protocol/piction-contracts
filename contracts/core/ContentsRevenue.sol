pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsRevenue.sol";
import "../interfaces/IContentsManager.sol";
// import "../interfaces/ISupporterPool.sol";
import "../utils/ValidValue.sol";
import "../utils/StringLib.sol";

contract ContentsRevenue is Ownable, IContentsRevenue, ValidValue {
    using SafeMath for uint256;
    using StringLib for string;

    IPictionNetwork private pictionNetwork;
    IContentsManager private contentsManager;
    // ISupporterPool private supporterPool;

    string public constant USERADOPTIONPOOL = "UserAdoptionPool";
    string public constant SUPPORTERPOOL = "SupporterPool";
    string public constant ECOSYSTEMFUND = "EcosystemFund";
    string public constant CONTENTSMANAGER = "ContentsManager";

    struct DistributionInfo {
        uint256 contentsDistributor;
        uint256 userAdoptionPool;
        uint256 ecosystemFund;
        uint256 supporterPool;
    }

    uint256 constant DECIMALS = 10 ** 18;

    constructor(address pictionNetworkAddress) public validAddress(pictionNetworkAddress) {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
        contentsManager = IContentsManager(pictionNetwork.getAddress(CONTENTSMANAGER));
        // supporterPool = ISupporterPool(pictionNetwork.getAddress(SUPPORTERPOOL));
    }

    /**
     * @dev 전송된 PXL을 각 비율별로 계산
     * @param cdRate ContentsDistributor의 분배 비율
     * @param contentHash 구매한 content의 hash
     * @param amount 전송받은 PXL 수량
     */
    function calculateDistributionPxl(
        uint256 cdRate, 
        string contentHash, 
        uint256 amount
    )
        external 
        view
        validRate(cdRate)
        returns (address[] memory addresses, uint256[] memory amounts)
    {
        require(amount > 0, "ContentsRevenue calculateDistributionPxl 0");
        require(!contentHash.isEmptyString(), "ContentsRevenue calculateDistributionPxl 1");
        
        addresses = new address[](4);
        amounts = new uint256[](4);

        address contentsProvider = contentsManager.getWriter(contentHash);
        require(contentsProvider != address(0), "ContentsRevenue calculateDistributionPxl 2");

        uint256 supporterPoolRate = 0; // supporterPool.getSupporterPoolRate(contentHash).div(DECIMALS);

        DistributionInfo memory distributionInfo = DistributionInfo(
            amount.mul(cdRate).div(DECIMALS),
            amount.mul(pictionNetwork.getRate(USERADOPTIONPOOL)).div(DECIMALS),
            amount.mul(pictionNetwork.getRate(ECOSYSTEMFUND)).div(DECIMALS),
            amount.mul(supporterPoolRate).div(DECIMALS)
        );

        addresses[0] = pictionNetwork.getAddress(USERADOPTIONPOOL);
        amounts[0] = distributionInfo.userAdoptionPool;
        
        addresses[1] = pictionNetwork.getAddress(ECOSYSTEMFUND);
        amounts[1] = distributionInfo.ecosystemFund;

        addresses[2] = pictionNetwork.getAddress(SUPPORTERPOOL);
        amounts[2] = distributionInfo.supporterPool;

        addresses[3] = contentsProvider;
        amounts[3] = amount.sub(distributionInfo.contentsDistributor).sub(distributionInfo.userAdoptionPool).sub(distributionInfo.ecosystemFund).sub(distributionInfo.supporterPool);
    }

    /**
     * @dev 저장된 주소를 업데이트
     */
    function updateAddress() external onlyOwner {
        contentsManager = IContentsManager(pictionNetwork.getAddress(CONTENTSMANAGER));
        // supporterPool = ISupporterPool(pictionNetwork.getAddress(SUPPORTERPOOL));
    }
}