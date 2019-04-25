pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IPictionNetwork.sol";
import "../interfaces/IUpdateAddress.sol";
import "../utils/ValidValue.sol";

contract PictionNetwork is IPictionNetwork, Ownable, ValidValue {

    mapping (string => bool) private registeredAddress;
    mapping (string => bool) private registeredRate;
    mapping (string => address) private contentsDistributor;

    // Managers: AccountsManager, ContentsManager
    // Core: ContentsRevenue
    // Tokens: PXL
    // Storages: AccountsStorage, ContentsStorage
    // Connectors: ELEConnector, PICConnector
    mapping (string => address) private addressList;

    // UserAdoptionPool, EcosystemFund
    mapping (string => uint256) distributeRate;

    /**
      * @dev Address 설정
      * @param contractName 설정하고자 하는 Contract 이름
      * @param pictionAddress 설정하고자 하는 Address
      */
    function setAddress(
        string contractName, 
        address pictionAddress
    )
        external 
        onlyOwner 
        validAddress(pictionAddress) 
    {
        addressList[contractName] = pictionAddress;
        registeredAddress[contractName] = true;

        emit SetAddress(msg.sender, contractName, pictionAddress);
    }

    /**
      * @dev Address 조회
      * @param contractName 조회하고자 하는 Contract 이름
      */
    function getAddress(string contractName) 
        external 
        view 
        returns(address pictionAddress) {
        require(registeredAddress[contractName], "Unregistered contract");

        pictionAddress = addressList[contractName];
    }

    /**
      * @dev Rate 설정
      * @param contractName 설정하고자 하는 Contract 이름
      * @param rate 설정하고자 하는 Rate
      */
    function setRate(
        string contractName, 
        uint256 rate
    )
        external 
        onlyOwner 
        validRate(rate) 
    {
        distributeRate[contractName] = rate;
        registeredRate[contractName] = true;

        emit SetRate(msg.sender, contractName, rate);
    }

    /**
      * @dev Rate 조회
      * @param contractName 조회하고자 하는 Contract 이름
      */
    function getRate(string contractName) 
        external 
        view 
        returns(uint256 rate) {
        require(registeredRate[contractName], "Unregistered contract");

        rate = distributeRate[contractName];
    }

    /**
      * @dev ContentsDistributor 설정
      * @param cdName 설정하고자 하는 ContentsDistributor 이름
      * @param cdAddress 설정하고자 하는 ContentsDistributor의 주소
      */
    function setContentsDistributor(
        string cdName,
        address cdAddress
    )
        external
        onlyOwner
        validString(cdName)
        validAddress(cdAddress)
    {
        contentsDistributor[cdName] = cdAddress;

        emit SetContentsDistributor(cdName, cdAddress);
    }

    /**
      * @dev ContentsDistributor 정보 조회
      * @param cdAddress 조회하고자 하는 ContentsDistributor의 주소
      */
    function getContentsDistributor(string cdName)
        external
        view
        returns(address cdAddress)
    {
        cdAddress = contentsDistributor[cdName];
    }

    /**
      * @dev Address를 업데이트
      * @param updateAddressList updateAddress를 호출할 Contract들의 주소
      */
    function updateAddress(
        address[] updateAddressList
    )
        external
        onlyOwner
    {
        for (uint256 i = 0; i < updateAddressList.length; i++) {
            IUpdateAddress(updateAddressList[i]).updateAddress();
        }
    }
}