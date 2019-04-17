pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsManager.sol";
import "../interfaces/IERC20.sol";
import "../utils/BytesLib.sol";

contract ContentsRevenue is Ownable {
    using SafeMath for uint256;
    using BytesLib for bytes;

    IPictionNetwork private pictionNetwork;
    IERC20 private pxlToken;

    uint256 constant DECIMALS = 10 ** 18;
    
    constructor(
        address pictionNetworkAddress
    )
        public 
    {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
        pxlToken = IERC20(pictionNetwork.getAddress("PXL"));
    }

    /**
     * @dev 위임된 권한을 이용하여 토큰 사용
     * @param from 발신자 주소
     * @param value 토큰 권리 위임 수량
     * @param token PXL 컨트랙트 주소
     * @param data 기타 파라미터 :
                    [Content Hash 66]
                    [Contents Distributor 20]
                    [Sale type 32]
                    [Supporter Pool Rate 32]
     *
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory data) public {
        require(address(this) != from, "Invalid buyer address.");
        require(pictionNetwork.getAddress("PXL") == token, "Invalid Pixel token address.");
        require(value > 0, "Received token must be greater than zero.");
        
        string memory contentHash = string(data.slice(0, 66));
        IContentsManager contentsManager = IContentsManager(pictionNetwork.getAddress("ContentsManager"));
        address contentsProvider = contentsManager.getWriter(contentHash);
        require(contentsProvider != address(0));

        string memory cdName;
        address contentsDistributor = data.toAddress(66);
        (cdName, ) = pictionNetwork.getCDInfo(contentsDistributor);
        require(bytes(cdName).length > 0);

        uint256 saleType = data.toUint(86);
        uint256 supporterPoolRate = data.toUint(118);
        
        pxlToken.transferFrom(from, address(this), value);
        _transferDistributePxl(from, contentsDistributor, supporterPoolRate, contentsProvider, value);

        // contentsManager.purchase(from, contentHash, saleType);
    }

    /**
     * @dev PXL을 각 비율별로 전송
     * @param from 발신자 주소
     * @param contentsDistributor ContentsDistributor 주소
     * @param supporterPoolRate SupporterPool 분배 비율
     * @param contentsProvider 작가 주소
     * @param amount 토큰 권리 위임 수량
     *
     */
    function _transferDistributePxl(address from, address contentsDistributor, uint256 supporterPoolRate, address contentsProvider, uint256 amount) internal {
        uint256 cdRate;
        (, cdRate) = pictionNetwork.getCDInfo(contentsDistributor);

        uint256 contentsDistributorAmount = amount.mul(cdRate).div(DECIMALS);
        uint256 userAdoptionPoolAmount = amount.mul(pictionNetwork.getRate("UserAdoptionPool")).div(DECIMALS);
        uint256 ecosystemFundAmount = amount.mul(pictionNetwork.getRate("EcosystemFund")).div(DECIMALS);
        uint256 supporterPoolAmount = amount.mul(supporterPoolRate).div(DECIMALS);

        uint256 contentsProviderAmount = amount.sub(contentsDistributorAmount).sub(userAdoptionPoolAmount).sub(ecosystemFundAmount).sub(supporterPoolAmount);

        if (contentsDistributorAmount > 0) {
            pxlToken.transfer(contentsDistributor, contentsDistributorAmount);
            emit Distribute(from, contentsDistributor, contentsDistributorAmount);
        }
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

    event Distribute(address indexed sender, address to, uint256 value);
}