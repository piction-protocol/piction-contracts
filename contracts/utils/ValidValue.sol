pragma solidity ^0.4.24;

contract ValidValue {
  modifier validRange(uint256 _value) {
      require(_value > 0);
      _;
  }

  modifier validAddress(address _account) {
      require(_account != address(0), "Invaild address: The address 0 is not allowed.");
      require(_account != address(this), "Invaild address: This address is Same address as contract.");
      _;
  }

  modifier validString(string _str) {
      require(bytes(_str).length > 0, "Invalid String: The string value must be at least one character.");
      _;
  }

  modifier validRate(uint256 _rate) {
      uint256 validDecimals = 10 ** 16;
      require((_rate/validDecimals) > 0, "Out of Range: The ratio must be greater then 0.");
      require((_rate/validDecimals) <= 100, "Out of Range: The ratio must be less then 100.");
      _;
  }
}
