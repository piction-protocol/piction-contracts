pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsRevenue.sol";
import "../interfaces/IERC20.sol";
import "../utils/BytesLib.sol";
import "../utils/StringLib.sol";
import "../utils/ValidValue.sol";

contract ContentsDistributor is Ownable, ValidValue {
    using SafeMath for uint256;
    using BytesLib for bytes;
    using StringLib for string;

    uint256 constant DECIMALS = 10 ** 18;   
    
    IPictionNetwork private pictionNetwork;
    IERC20 pxlToken;
    
    uint256 private staking;
    uint256 distributionRate;
    address private contentsDistributor;
    string name;
    
    string public constant CONTENTSREVENUE = "ContentsRevenue";
    
    constructor(
        address pictionNetworkAddress,
        uint256 initialStaking,
        uint256 cdRate,
        address cdAddress,
        string cdName
    )
        public 
        validRange(initialStaking)
        validRate(cdRate)
        validAddress(pictionNetworkAddress)
        validAddress(cdAddress)
        validString(cdName)
    {
        pictionNetwork = IPictionNetwork(pictionNetworkAddress);
        pxlToken = IERC20(pictionNetwork.getAddress("PXL"));
        
        distributionRate = cdRate;
        staking = initialStaking;
        contentsDistributor = cdAddress;
        name = cdName;
    }

    /**
     * @dev 위임된 권한을 이용하여 토큰 사용
     * @param from 발신자 주소
     * @param value 토큰 권리 위임 수량
     * @param token PXL 컨트랙트 주소
     * @param data 기타 파라미터 :
                    [Content Hash 66]
                    [Sale type 32]
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory data) public {
        require(pxlToken == token, "ContentsDistributor receiveApproval 0");
        require(value > 0, "ContentsDistributor receiveApproval 1");
        
        string memory contentHash = string(data.slice(0, 66));
        require(!contentHash.isEmptyString(), "ContentsDistributor receiveApproval 2");
        
        uint256 saleType = data.toUint(66);
        
        pxlToken.transferFrom(from, address(this), value);

        IContentsRevenue contentsRevenue = IContentsRevenue(pictionNetwork.getAddress(CONTENTSREVENUE));
        (address[] memory addresses, uint256[] memory amounts) = contentsRevenue.calculateDistributionPxl(distributionRate, contentHash, value);
        
        for (uint256 i = 0; i < addresses.length; i++) { 
            if (amounts[i] > 0) {
                pxlToken.transfer(addresses[i], amounts[i]);
            }
        }
        // contentsManager.purchase(from, contentHash, saleType);
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
        require(balance > staking, "ContentsDistributor sendToContentsDistributor 0");
        
        pxlToken.transfer(contentsDistributor, balance.sub(staking));

        emit SendToContentsDistributor(balance.sub(staking));
    }

    event SetRate(uint256 rate);
    event SendToContentsDistributor(uint256 value);
}