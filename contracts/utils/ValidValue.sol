pragma solidity ^0.4.24;

contract ValidValue {
  modifier validRange(uint256 value) {
      //Out of Range: The value must be greater than 0.
      require(value > 0, "ValidValue validRange 0");
      _;
  }

  modifier validAddress(address account) {
      //Invaild address: The address 0 is not allowed.
      require(account != address(0), "ValidValue validAddress 0");
      //Invaild address: This address is Same address as current contract.
      require(account != address(this), "ValidValue validAddress 1");
      _;
  }

  modifier validString(string str) {
      //Invalid String: The string value must be at least one character.
      require(bytes(str).length > 0, "ValidValue validString 0");
      _;
  }

  modifier validRate(uint256 rate) {
      uint256 validDecimals = 10 ** 18;
      //Out of Range: The ratio must be less than 1.
      require(rate <= validDecimals, "ValidValue validRate 0");
      _;
  }
}
