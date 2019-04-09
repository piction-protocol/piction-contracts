pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/TimeLib.sol";
import "../utils/ValidValue.sol";

contract PictionNetwork is IPictionNetwork, Ownable, ValidValue {

  // AccountsManager
  // ContentsManager
  mapping (string => address) private addressList;

  /**
    * @dev Address 설정
    * @param contractName 설정하고자 하는 Address 이름
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
    * @param contractName 조회하고자 하는 Address 이름
    */
  function getAddress(string contractName) 
      external 
      view 
      returns(address pictionAddress) {

      pictionAddress = addressList[contractName];
  }
}