pragma solidity ^0.4.24;

contract ValidValue {
  modifier validRange(uint256 value) {
      require(value > 0, "Out of Range: The value must be greater than 0.");
      _;
  }

  modifier validAddress(address account) {
      require(account != address(0), "Invaild address: The address 0 is not allowed.");
      require(account != address(this), "Invaild address: This address is Same address as current contract.");
      _;
  }

  modifier validString(string str) {
      require(bytes(str).length > 0, "Invalid String: The string value must be at least one character.");
      _;
  }

  modifier validRate(uint256 rate) {
      uint256 validDecimals = 10 ** 18;
      require(rate <= validDecimals, "Out of Range: The ratio must be less than 1.");
      _;
  }
}
