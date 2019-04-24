pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";

import "../interfaces/IPIC.sol";
import "../utils/ExtendsOwnable.sol";

contract PIC is IPIC, ExtendsOwnable {
    using SafeMath for uint256;

    mapping (string => uint256) private _totalSupply;
    mapping (string => mapping (address => uint256)) private _balances;

    function() external payable {
        revert();
    }

    function totalSupply(string contentsHash) public view returns (uint256) {
        return _totalSupply[contentsHash];
    }

    function balanceOf(string contentsHash, address owner) public view returns (uint256) {
        return _balances[contentsHash][owner];
    }

    function transfer(string contentsHash, address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "PIC transfer 0");
        require(_totalSupply[contentsHash] > 0, "PIC transfer 1");
        
        _balances[contentsHash][from] = _balances[contentsHash][from].sub(value);
        _balances[contentsHash][to] = _balances[contentsHash][to].add(value);
        emit Transfer(from, to, value, contentsHash);

        return true;
    }

    function burn(string contentsHash, address from, uint256 value) external onlyOwner {
        require(from != address(0), "PIC burn 0");
        require(_totalSupply[contentsHash] > 0, "PIC burn 1");

        _totalSupply[contentsHash] = _totalSupply[contentsHash].sub(value);
        _balances[contentsHash][from] = _balances[contentsHash][from].sub(value);
        emit Transfer(from, address(0), value, contentsHash);
    }

    function mint(string contentsHash, uint256 initialValue) external onlyOwner {
        require(_totalSupply[contentsHash] == 0, "PIC mint 0");

        _totalSupply[contentsHash] = _totalSupply[contentsHash].add(initialValue);
        _balances[contentsHash][msg.sender] = _balances[contentsHash][msg.sender].add(initialValue);
        emit Transfer(address(0), msg.sender, initialValue, contentsHash);
    }

    // TODO approve and call과 같은 기능이 필요한지는 sale contract 만들면서 생각해야함
    // approve and call이 들어갈 경우 transferFrom, _allowed mapping 필요..
}