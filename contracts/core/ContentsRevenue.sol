pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsManager.sol";
import "../interfaces/IERC20.sol";
import "../utils/BytesLib.sol";
import "../utils/ValidValue.sol";

contract ContentsRevenue is Ownable, ValidValue {
    using SafeMath for uint256;
    using BytesLib for bytes;

    IPictionNetwork private pictionNetwork;
    IERC20 private pxlToken;

    uint256 distributionRate;
    uint256 private staking;
    address private contentsDistributor;

    uint256 constant DECIMALS = 10 ** 18;
    
    constructor(
        address pictionNetworkAddress,
        uint256 initialStaking,
        uint256 cdRate,
        address cdAddress
    )
        public 
        validRange(initialStaking)
        validRate(cdRate)
        validAddress(pictionNetworkAddress)
        validAddress(cdAddress)
    {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
        pxlToken = IERC20(pictionNetwork.getAddress("PXL"));
        
        distributionRate = cdRate;
        staking = initialStaking;
        contentsDistributor = cdAddress;
    }

    /**
     * @dev 위임된 권한을 이용하여 토큰 사용
     * @param from 발신자 주소
     * @param value 토큰 권리 위임 수량
     * @param token PXL 컨트랙트 주소
     * @param data 기타 파라미터 :
                    [Content Hash 66]
                    [Sale type 32]
                    [Supporter Pool Rate 32]
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory data) public {
        require(address(this) != from, "ContentsRevenue receiveApproval 0");
        require(pictionNetwork.getAddress("PXL") == token, "ContentsRevenue receiveApproval 1");
        require(value > 0, "ContentsRevenue receiveApproval 2");
        
        string memory contentHash = string(data.slice(0, 66));
        IContentsManager contentsManager = IContentsManager(pictionNetwork.getAddress("ContentsManager"));
        address contentsProvider = contentsManager.getWriter(contentHash);
        require(contentsProvider != address(0), "ContentsRevenue receiveApproval 3");

        uint256 saleType = data.toUint(66);
        uint256 supporterPoolRate = data.toUint(98);
        
        pxlToken.transferFrom(from, address(this), value);
        _transferDistributePxl(from, supporterPoolRate, contentsProvider, value);

        // contentsManager.purchase(from, contentHash, saleType);
    }

    /**
     * @dev PXL을 각 비율별로 전송
     * @param from 발신자 주소
     * @param supporterPoolRate SupporterPool 분배 비율
     * @param contentsProvider 작가 주소
     * @param amount 토큰 권리 위임 수량
     */
    function _transferDistributePxl(address from, uint256 supporterPoolRate, address contentsProvider, uint256 amount) internal {
        uint256 contentsDistributorAmount = amount.mul(distributionRate).div(DECIMALS);
        uint256 userAdoptionPoolAmount = amount.mul(pictionNetwork.getRate("UserAdoptionPool")).div(DECIMALS);
        uint256 ecosystemFundAmount = amount.mul(pictionNetwork.getRate("EcosystemFund")).div(DECIMALS);
        uint256 supporterPoolAmount = amount.mul(supporterPoolRate).div(DECIMALS);

        uint256 contentsProviderAmount = amount.sub(contentsDistributorAmount).sub(userAdoptionPoolAmount).sub(ecosystemFundAmount).sub(supporterPoolAmount);

        if (userAdoptionPoolAmount > 0) {
            pxlToken.transfer(pictionNetwork.getAddress("UserAdoptionPool"), userAdoptionPoolAmount);
            emit Distribute(from, pictionNetwork.getAddress("UserAdoptionPool"), userAdoptionPoolAmount);
        }
        if (ecosystemFundAmount > 0) {
            pxlToken.transfer(pictionNetwork.getAddress("EcosystemFund"), ecosystemFundAmount);
            emit Distribute(from, pictionNetwork.getAddress("EcosystemFund"), ecosystemFundAmount);
        }
        if (supporterPoolAmount > 0) {
            pxlToken.transfer(pictionNetwork.getAddress("SupporterPool"), supporterPoolAmount);
            emit Distribute(from, pictionNetwork.getAddress("SupporterPool"), supporterPoolAmount);
        }
        if (contentsProviderAmount > 0) {
            pxlToken.transfer(contentsProvider, contentsProviderAmount);
            emit Distribute(from, contentsProvider, contentsProviderAmount);
        }
    }

    /**
     * @dev ContentsDistributor의 분배 비율을 설정
     * @param cdRate 분배 비율
     */
    function setRate(uint256 cdRate) external onlyOwner validRate(cdRate) {
        distributionRate = cdRate;

        emit SetRate(cdRate);
    }

    /**
     * @dev ContentsDistributor에 분배된 토큰을 전송
     */
    function sendToContentsDistributor() external onlyOwner {
        uint256 balance = pxlToken.balanceOf(address(this));
        require(balance > staking, "ContentsRevenue sendToContentsDistributor 0");
        
        pxlToken.transfer(contentsDistributor, balance.sub(staking));
    }

    event SetRate(uint256 rate);
    event Distribute(address indexed sender, address to, uint256 value);
}