pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/ValidValue.sol";

contract PictionNetwork is IPictionNetwork, Ownable, ValidValue {

    mapping (string => bool) private registedAddress;
    mapping (string => bool) private registedRate;

    // Managers: AccountsManager, ContentsManager
    // Core: ContentsRevenue
    // Tokens: PXL
    // Storages: AccountsStorage, ContentsStorage
    // Connectors: ELEConnector, PICConnector
    mapping (string => address) private addressList;

    // ContentsDistributor, UserAdoptionPool, EcosystemFund, SupporterPool
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
        registedAddress[contractName] = true;

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
        require(registedAddress[contractName], "Unregisted contract");

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
        registedRate[contractName] = true;

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
        require(registedRate[contractName], "Unregisted contract");

        rate = distributeRate[contractName];
    }
}