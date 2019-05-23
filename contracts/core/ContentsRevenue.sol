pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsRevenue.sol";
import "../interfaces/IProjectManager.sol";
import "../interfaces/IUpdateAddress.sol";
// import "../interfaces/ISupporterPool.sol";
import "../utils/ValidValue.sol";

contract ContentsRevenue is Ownable, IContentsRevenue, ValidValue, IUpdateAddress {
    using SafeMath for uint256;

    IPictionNetwork private pictionNetwork;
    IProjectManager private projectManager;
    // ISupporterPool private supporterPool;
    
    uint256 private constant DECIMALS = 10 ** 18;
    string private constant USERADOPTIONPOOL = "UserAdoptionPool";
    string private constant SUPPORTERPOOL = "SupporterPool";
    string private constant ECOSYSTEMFUND = "EcosystemFund";
    string private constant PROJECTMANAGER = "ProjectManager";

    struct DistributionInfo {
        uint256 contentsDistributor;
        uint256 userAdoptionPool;
        uint256 ecosystemFund;
        uint256 supporterPool;
    }

    constructor(address pictionNetworkAddress) public validAddress(pictionNetworkAddress) {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
        projectManager = IProjectManager(pictionNetwork.getAddress(PROJECTMANAGER));
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
        validString(contentHash)
        returns(address[] memory addresses, uint256[] memory amounts)
    {
        require(amount > 0, "ContentsRevenue calculateDistributionPxl 0");
        
        addresses = new address[](4);
        amounts = new uint256[](4);

        address contentsProvider = projectManager.getWriter(contentHash);
        require(contentsProvider != address(0), "ContentsRevenue calculateDistributionPxl 1");

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
    function updateAddress() external {
        require(msg.sender == address(pictionNetwork), "ContentsRevenue updateAddress 0");
        
        address cManager = pictionNetwork.getAddress(PROJECTMANAGER);
        emit UpdateAddress(address(projectManager), cManager);
        projectManager = IProjectManager(cManager);

        // supporterPool = ISupporterPool(pictionNetwork.getAddress(SUPPORTERPOOL));
    }
}