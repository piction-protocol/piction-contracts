pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IContentsRevenue.sol";
import "../interfaces/IUpdateAddress.sol";
import "../interfaces/IProjectManager.sol";
import "../interfaces/IWithdraw.sol";
import "../utils/BytesLib.sol";
import "../utils/StringLib.sol";
import "../utils/ValidValue.sol";

contract ContentsDistributor is Ownable, ValidValue, IUpdateAddress, IWithdraw {
    using SafeMath for uint256;
    using BytesLib for bytes;
    using StringLib for string;

    IPictionNetwork private pictionNetwork;
    IERC20 public pxlToken;
    IContentsRevenue private contentsRevenue;
    
    uint256 private constant DECIMALS = 10 ** 18;   
    string private constant CONTENTSREVENUE = "ContentsRevenue";
    string private constant PROJECTMANAGER = "ProjectManager";
    string private constant PXL = "PXL";

    uint256 private stakingAmount;
    uint256 public distributionRate;
    address private contentsDistributor;
    string public name;
    
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
        pxlToken = IERC20(pictionNetwork.getAddress(PXL));
        contentsRevenue = IContentsRevenue(pictionNetwork.getAddress(CONTENTSREVENUE));
        
        distributionRate = cdRate;
        stakingAmount = initialStaking;
        contentsDistributor = cdAddress;
        name = cdName;
    }

    modifier onlyContentsDistributor() {
        require(msg.sender == contentsDistributor, "onlyContentsDistributor: caller is not the contentsDistributor");
        _;
    }

    /**
     * @dev 위임된 권한을 이용하여 토큰 사용
     * @param from 발신자 주소
     * @param value 토큰 권리 위임 수량
     * @param token PXL 컨트랙트 주소
     * @param data 기타 파라미터 :
                    [Project hash 66]
     */
    function receiveApproval(
        address from,
        uint256 value,
        address token,
        bytes memory data
    ) 
        public 
    {
        require(address(pxlToken) == token, "ContentsDistributor receiveApproval 0");
        require(value > 0, "ContentsDistributor receiveApproval 1");

        string memory projectHash = string(data);
        address cp = IProjectManager(pictionNetwork.getAddress(PROJECTMANAGER)).getProjectOwner(projectHash);
        require(cp != address(0), "ContentsDistributor receiveApproval 2");
        
        pxlToken.transferFrom(from, address(this), value);

        (address[] memory addresses, uint256[] memory amounts) = contentsRevenue.calculateDistributionPxl(distributionRate, cp, value);
        
        for (uint256 i = 0; i < addresses.length; i++) { 
            if (amounts[i] > 0) {
                pxlToken.transfer(addresses[i], amounts[i]);
            }
        }

        emit Subscription(from, cp, projectHash, value);
    }

     /**
     * @dev ContentsDistributor의 Staking 수량을 설정
     * @param staking 설정할 staking
     */
    function setStaking(uint256 staking) external onlyOwner {
        stakingAmount = staking;

        emit SetStaking(name, staking);
    }

    /**
     * @dev ContentsDistributor의 분배 비율을 설정
     * @param cdRate 분배 비율
     */
    function setRate(uint256 cdRate) external onlyOwner validRate(cdRate) {
        distributionRate = cdRate;

        emit SetRate(name, cdRate);
    }

    /**
     * @dev ContentsDistributor의 출금 주소를 설정
     * @param cdAddress 설정할 주소
     */
    function setCDAddress(address cdAddress) external onlyOwner validAddress(cdAddress) {
        contentsDistributor = cdAddress;

        emit SetCDAddress(name, cdAddress);
    }

    /**
     * @dev ContentsDistributor에 분배된 PXL 출금
     */
    function withdrawPXL() external onlyContentsDistributor {
        uint256 balance = pxlToken.balanceOf(address(this));
        require(balance > stakingAmount, "ContentsDistributor sendToContentsDistributor 0");
        
        pxlToken.transfer(contentsDistributor, balance.sub(stakingAmount));

        emit WithdrawPXL(msg.sender, balance.sub(stakingAmount));
    }

    /**
     * @dev 저장된 주소를 업데이트
     */
    function updateAddress() external {
        require(msg.sender == address(pictionNetwork), "ContentsDistributor updateAddress 0");

        contentsRevenue = IContentsRevenue(pictionNetwork.getAddress(CONTENTSREVENUE));
    }

    event SetStaking(string name, uint256 value);
    event SetRate(string name, uint256 rate);
    event SetCDAddress(string name, address cdAddress);
    event Subscription(address indexed buyer, address indexed creator, string hash, uint256 price);
}