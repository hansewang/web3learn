// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


// 所有人都可以存钱
// ETH
// 只有合约 owner 才可以取钱
// 只要取钱，合约就销毁掉 selfdestruct
// 扩展：支持主币以外的资产
// ERC20
// ERC721

contract Bank {
        // 状态变量
    address public immutable owner;
    // 事件
    event Deposit(address _ads, uint256 amount);
    event Withdraw(uint256 amount);

    // receive
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
    // 构造函数
    constructor() payable {
        owner = msg.sender;
    }

    // 将权限检查抽取出来成为一个修饰器_
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call.");
        _;
    }

    // 方法
    function withdraw() external onlyOwner {
        emit Withdraw(address(this).balance);
        selfdestruct(payable(msg.sender));
    }
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}