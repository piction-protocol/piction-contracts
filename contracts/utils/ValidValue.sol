pragma solidity ^0.4.24;

contract ValidValue {
  modifier validRange(uint256 value) {
      //Out of Range: The value must be greater than 0.
      require(_validRange(value), "ValidValue validRange 0");
      _;
  }

  modifier validAddress(address account) {
      //Invaild address: The address 0 is not allowed.
      require(_validAddressZero(account), "ValidValue validAddress 0");
      //Invaild address: This address is Same address as current contract.
      require(_validAddressThis(account), "ValidValue validAddress 1");
      _;
  }

  modifier validString(string str) {
      //Invalid String: The string value must be at least one character.
      require(_validString(str), "ValidValue validString 0");
      _;
  }

  modifier validRate(uint256 rate) {
      //Out of Range: The ratio must be less than 1.
      require(_validRate(rate), "ValidValue validRate 0");
      _;
  }

  function _validRange(uint256 value) internal pure returns(bool) {
      return (value > 0);
  }

  function _validAddressZero(address account) internal pure returns(bool) {
      return (account != address(0));
  }

  function _validAddressThis(address account) internal view returns(bool) {
      return (account != address(this));
  }

  function _validString(string str) internal pure returns(bool) {
      return (bytes(str).length > 0);
  }

  function _validRate(uint256 rate) internal pure returns(bool) {
      uint256 validDecimals = 10 ** 18;
      return (rate <= validDecimals);
  }
}
