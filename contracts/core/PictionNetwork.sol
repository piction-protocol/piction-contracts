pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../interfaces/IPictionNetwork.sol";
import "../utils/TimeLib.sol";

contract PictionNetwork is IPictionNetwork, Ownable {

  // accounts
  // contents
  mapping (string => address) private managers;

  modifier validAddress(address addr) {
      require(addr != address(0), "Invaild address: Address 0 is not allowed.");
      require(addr != address(this), "Invaild address: Same address as User Adoption Pool contact");
      _;
  }

  /**
    * @dev PIC 발행
    * @param name 설정하고자 하는 Manager 이름
    * @param manager 설정하고자 하는 Manager Address
    */
  function setManager(
      string name, 
      address manager
  )
     external 
     onlyOwner 
     validAddress(manager) 
  {
      managers[name] = manager;

      emit SetManager(msg.sender, name, manager, TimeLib.currentTime());
  }

  /**
    * @dev Manager Address 조회
    * @param name 조회하고자 하는 Manager 이름
    */
  function getManager(string name) 
      external 
      view 
      returns(address manager) {

      manager = managers[name];
  }
}