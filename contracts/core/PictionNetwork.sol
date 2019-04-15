pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/TimeLib.sol";
import "../utils/ValidValue.sol";

contract PictionNetwork is IPictionNetwork, Ownable, ValidValue {

  // Managers: AccountsManager, ContentsManager, PostManager
  // Core: ContentsRevenue
  // Tokens: PXL
  // Storages: AccountsStorage, ContentsStorage, PostStorage
  // Connectors: ELEConnector, PICConnector
  mapping (string => address) private addressList;

  // ContentsDistributor, UserAdoptionPool, DepositPool, EcosystemFund, SupporterPool, ContensProvider, Translator, Marketer
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

      emit SetAddress(msg.sender, contractName, pictionAddress, TimeLib.currentTime());
  }

  /**
    * @dev Address 조회
    * @param contractName 조회하고자 하는 Contract 이름
    */
  function getAddress(string contractName) 
      external 
      view 
      returns(address pictionAddress) {

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

      emit SetRate(msg.sender, contractName, rate, TimeLib.currentTime());
  }

  /**
    * @dev Rate 조회
    * @param contractName 조회하고자 하는 Contract 이름
    */
  function getRate(string contractName) 
      external 
      view 
      returns(uint256 rate) {

      rate = distributeRate[contractName];
  }
}