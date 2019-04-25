pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/Math.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IPIC.sol";
import "../interfaces/IStorage.sol";
import "../interfaces/IPictionNetwork.sol";
import "../interfaces/ISupportStorage.sol";
import "../interfaces/IContentsManager.sol";

import "../tokens/ContractReceiver.sol";

import "../utils/TimeLib.sol";
import "../utils/BytesLib.sol";
import "../utils/ExtendsOwnable.sol";


/**
    SupportSaleManager 와 SupportTradeManager로 분리하여 관리할지 생각.....
 */
contract SupportSaleManager is ExtendsOwnable {
    using Math for uint256;
    using SafeMath for uint256;
    using BytesLib for bytes;

    string public constant PXL_NAME = "PXL";
    string public constant PIC_NAME = "PIC";
    string public constant STORAGE_NAME = "SupportStorage";
    string public constant CONTENTS_MANAGER_NAME = "ContentsManager";

    string public constant CREATE_TAG = "CreatePicSale";
    string public constant PURCHASE_TAG = "PurchasePic";
    string public constant REFUND_TAG = "RefundPic";

    IPIC iPic;
    IERC20 iPxl;
    IStorage iStorage;
    IPictionNetwork iPiction;
    ISupportStorage iSupportStorage;
    IContentsManager iContentsManager;

    constructor (address pictionNetwork) public {
        require(pictionNetwork != address(0), "SupportSaleManager constructor 0");

        iPiction = IPictionNetwork(pictionNetwork);

        iPic = IPIC(iPiction.getAddress(PIC_NAME));
        iPxl = IERC20(iPiction.getAddress(PXL_NAME));
        iSupportStorage = ISupportStorage(iPiction.getAddress(STORAGE_NAME));
        iStorage = IStorage(iPiction.getAddress(STORAGE_NAME));

        iContentsManager = IContentsManager(iPiction.getAddress(CONTENTS_MANAGER_NAME));
    }

    // 후원 생성
    function createPicSale(string contentsHash, uint256 picPrice) external {
        require(picPrice.div(1 ether) > 0, "SupportSaleManager createPicSale 0");
        require(iContentsManager.getWriter(contentsHash) == msg.sender, "SupportSaleManager createPicSale 1");

        uint256 initialValue = 10000;
        uint256 endTime = TimeLib.currentTime().add(30 days * 1000);
        
        iStorage.setBooleanValue(contentsHash, true, CREATE_TAG);
        iStorage.setAddressValue(contentsHash, msg.sender, CREATE_TAG);
        iSupportStorage.setSaleValue(contentsHash, picPrice, picPrice.mul(initialValue), endTime, CREATE_TAG);

        iPic.mint(contentsHash, initialValue);
    }

    // 후원 취소
    function cancelPicSale(string contentsHash) external {
        // 구매 유저 Address 목록 필요..
        // 목록 관리 정책 정해지면 추후 구현..
        // 작가가 지불해야하는 취소 수수료는 어떻게 할지??
    }

    // 후원증 구매(거래는 처리 안함, 컨트랙트 분리)
    function receiveApproval(address from, uint256 value, address token, bytes memory data) public {
        require(value > 1 ether, "SupportSaleManager receiveApproval 0");
        require(address(iPxl) == token, "SupportSaleManager receiveApproval 1");
        require(data.length == 66, "SupportSaleManager receiveApproval 2");

        string memory contentsHash = string(data.slice(0, 66));
        iPxl.transferFrom(from, address(this), value);
        purchasePic(contentsHash, from, value);
    }

    // 구매 처리
    function purchasePic(string contentsHash, address buyer, uint256 amount) private {
        require(iStorage.getBooleanValue(contentsHash), "SupportSaleManager purchasePic 0");

        (,uint256 maxcap,,uint256 pxlRaised) = iSupportStorage.getSaleValue(contentsHash);

        uint256 refundAmount;
        uint256 purchaseAmount = amount;
        if(maxcap < pxlRaised.add(amount)) {
            refundAmount = pxlRaised.add(amount).sub(maxcap);
            purchaseAmount = amount.sub(refundAmount);

            iPxl.transfer(buyer, refundAmount);
        }
        iSupportStorage.setPxlRaised(contentsHash, purchaseAmount, PURCHASE_TAG);

        purchaseAmount = purchaseAmount.add(iSupportStorage.getPxlAmount(contentsHash, buyer));
        iSupportStorage.setPxlAmount(contentsHash, buyer, purchaseAmount, PURCHASE_TAG);
    }

    // PIC 환불
    function refundPic(string contentsHash) external {
        uint256 refundAmount = iSupportStorage.getPxlAmount(contentsHash, msg.sender);
        require(refundAmount > 0, "SupportSaleManager refundPic 0");

        uint256 pxlRaised = iSupportStorage.getPxlRaised(contentsHash);
        iSupportStorage.setPxlRaised(contentsHash, pxlRaised.sub(refundAmount), REFUND_TAG);
        iSupportStorage.setPxlAmount(contentsHash, msg.sender, 0, REFUND_TAG);
        
        iPxl.transfer(msg.sender, refundAmount);
    }

    // PIC 지급 
    function withDrawPic(string contentsHash) external {
        require(iStorage.getAddressValue(contentsHash) == msg.sender, "SupportSaleManager withDrawPic 0");
        
        (,uint256 maxcap,uint256 endTime,uint256 pxlRaised) = iSupportStorage.getSaleValue(contentsHash);
        require(endTime >= TimeLib.currentTime() || maxcap == pxlRaised, "SupportSaleManager withDrawPic 1");

        // 목록 관리 정책 정해지면 추후 구현
    }
}