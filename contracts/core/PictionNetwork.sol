pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/TimeLib.sol";

contract PictionNetwork is IPictionNetwork, Ownable {

  // Accounts
  // Contents
  mapping (string => address) private managers;

  modifier validAddress(address addr) {
      require(addr != address(0), "Invaild address: Address 0 is not allowed.");
      require(addr != address(this), "Invaild address: Same address as User Adoption Pool contact");
      _;
  }

  /**
    * @dev PIC 발행
    * @param manager 설정하고자 하는 Manager 이름
    * @param managerAddr 설정하고자 하는 Manager Address
    */
  function setManager(
      string manager, 
      address managerAddr
  )
     external 
     onlyOwner 
     validAddress(managerAddr) 
  {
      managers[manager] = managerAddr;

      emit SetManager(msg.sender, manager, managerAddr, TimeLib.currentTime());
  }

  /**
    * @dev Manager Address 조회
    * @param manager 조회하고자 하는 Manager 이름
    */
  function getManager(string manager) 
      external 
      view 
      returns(address managerAddr) {

      managerAddr = managers[manager];
  }
}