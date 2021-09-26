// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./Token.sol";

contract Bank {
    Token public tokenContract;

    mapping(address => uint256) private balances;
    address public owner;
    uint256 public epoch;
    uint256 public timeUnit;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    constructor(
        address _tokenAddress,
        uint256 _timeUnit
    ) {
        tokenContract = Token(_tokenAddress);
        owner = msg.sender;
        epoch = block.timestamp;
        timeUnit = _timeUnit;
    }

    function deposit() public payable {
        require(block.timestamp < epoch + timeUnit, "Deposit time was ended");
        require(msg.value > 0, "Deposit amount is not positive");

        tokenContract.mint(msg.sender, msg.value);
        balances[msg.sender] += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public payable {
        require(amount > 0, "Withdraw amount is not positive");
        require(balances[msg.sender] > amount, "Balance is less than withdraw amount");

        tokenContract.burn(msg.sender, amount);
        balances[msg.sender] -= amount;

        emit Withdraw(msg.sender, amount);
    }

    function balance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
