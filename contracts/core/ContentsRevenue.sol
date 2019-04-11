pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
// import "../interfaces/IContentsManager.sol";
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
                    [Content Hash 32]
                    [Contents Distributor 20]
                    [Sale type 32]
                    [Marketer 주소 20]
                    [Translator 주소 20]
     *
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory data) public {
        require(address(this) != from, "Invalid buyer address.");
        require(pictionNetwork.getAddress("PXL") == token, "Invalid Pixel token address.");

        address contentHash = data.toByte(0);
        address contentsDistributor = data.toAddress(32);
        uint256 saleType = data.toUint(52);
        // uint256 marketer = data.toAddress(84);
        // address translator = data.toAddress(104);

        // IContentsManager contentsManager = IContentsManager(pictionNetwork.getAddress("ContentsManager"));
        // bool hasSupporter = contentsManager.hasSupporter(contentHash);
        // address contentsProvider = contentsManager.getWriter(contentHash);

        if (value > 0) {
            require(pxlToken.balanceOf(from) >= value, "Check buyer token amount.");
            pxlToken.transferFrom(from, address(this), value);

            // _transferDistributePxl(from, contentsProvider, hasSupporter, value);
        }

        // contentsManager.purchase(from, contentHash, saleType);
    }

    /**
     * @dev PXL을 각 비율별로 전송
     * @param from 발신자 주소
     * @param contentsDistributor ContentsDistributor 주소
     * @param hasSupporter SupporterPool 분배 유무
     * @param contentsProvider 작가 주소
     * @param amount 토큰 권리 위임 수량
     *
     */
    function _transferDistributePxl(address from, address contentsDistributor, bool hasSupporter, address contentsProvider, uint256 amount) internal {
        uint256 contentsDistributorAmount = amount.mul(pictionNetwork.getRate("ContentsDistributor")).div(DECIMALS);
        uint256 userAdoptionPoolAmount = amount.mul(pictionNetwork.getRate("UserAdoptionPool")).div(DECIMALS);
        uint256 ecosystemFundAmount = amount.mul(pictionNetwork.getRate("EcosystemFund")).div(DECIMALS);
        uint256 supporterPoolAmount = 0;
        if (hasSupporter) {
            supporterPoolAmount = amount.mul(pictionNetwork.getRate("SupporterPool")).div(DECIMALS);
        }
        // uint256 depositPoolAmount = amount.mul(pictionNetwork.getRate("DepositPool")).div(DECIMALS);
        // uint256 marketerAmount = amount.mul(pictionNetwork.getRate("Marketer")).div(DECIMALS);
        // uint256 TranslatorAmount = amount.mul(pictionNetwork.getRate("Translator")).div(DECIMALS);
        
        uint256 contentsProviderAmount = amount.sub(contentsDistributorAmount).sub(userAdoptionPoolAmount).sub(ecosystemFundAmount).sub(supporterPoolAmount);//.sub(depositPoolAmount).sub(marketerAmount).sub(translatorAmount);
        
        address userAdoptionPool = pictionNetwork.getAddress("UserAdoptionPool");
        address ecosystemFund = pictionNetwork.getAddress("EcosystemFund");
        address supporterPool = pictionNetwork.getAddress("SupporterPool");
        // address depositPool = pictionNetwork.getAddress("DepositPool");
        
        if (contentsDistributorAmount > 0) {
            pxlToken.transfer(contentsDistributor, contentsDistributorAmount);
            emit Distribute(from, contentsDistributor, contentsDistributorAmount);
        }
        if (userAdoptionPoolAmount > 0) {
            pxlToken.transfer(userAdoptionPool, userAdoptionPoolAmount);
            emit Distribute(from, userAdoptionPool, userAdoptionPoolAmount);
        }
        if (ecosystemFundAmount > 0) {
            pxlToken.transfer(ecosystemFund, ecosystemFundAmount);
            emit Distribute(from, userAdoptionPool, ecosystemFundAmount);
        }
        if (supporterPoolAmount > 0) {
            pxlToken.transfer(supporterPool, supporterPoolAmount);
            emit Distribute(from, supporterPool, supporterPoolAmount);
        }
        // if (depositPoolAmount > 0) {
        //     pxlToken.transfer(ecosystemFund, depositPoolAmount);
        //     emit Distribute(from, ecosystemFund, depositPoolAmount);
        // }
        // if (marketerAmount > 0) {
        //     pxlToken.transfer(marketer, marketerAmount);
        //     emit Distribute(from, marketer, marketerAmount);
        // }
        // if (translatorAmount > 0) {
        //     pxlToken.transfer(translator, translatorAmount);
        //     emit Distribute(from, translator, translatorAmount);
        // }
        if (contentsProviderAmount > 0) {
            pxlToken.transfer(contentsProvider, contentsProviderAmount);
            emit Distribute(from, contentsProvider, contentsProviderAmount);
        }
    }

    event Distribute(address indexed sender, address to, uint256 value);
}