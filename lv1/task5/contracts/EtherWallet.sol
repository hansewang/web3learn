// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
    这一个实战主要是加深大家对 3 个取钱方法的使用。

    任何人都可以发送金额到合约
    只有 owner 可以取款
    3 种取钱方式
*/
contract EtherWallet {
    // 钱包拥有者
    address payable public immutable owner;
    // 日志事件
    event Log(string funName, address from, uint256 value, bytes data);

    // 创建钱包，当前用户写入钱包拥有者
    constructor() {
        owner = payable(msg.sender);
    }
    // 定义接收函数, 记录事件
    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }

    // 转出100Wei, Gas固定为2300
    // 向指定地址转账，失败时抛出异常（仅 address payable 可以使用）
    // 异常无法处理
    function withdraw1() external {
        require(msg.sender == owner, "Not owner");
        // owner.transfer 相比 msg.sender 更消耗Gas
        // owner.transfer(address(this).balance);
        payable(msg.sender).transfer(100);
    }
    // 转出200Wei, Gas固定为2300
    // 向指定地址转账，但失败时不会抛出异常，而是返回布尔值（仅 address payable 可以使用）
    // 异常可以处理
    function withdraw2() external {
        require(msg.sender == owner, "Not owner");
        bool success = payable(msg.sender).send(200);
        require(success, "Send Failed");
    }
    // 转出所有金额, 可以指定Gas，这里指定300
    // 使用 call 函数，你可以与合约地址进行交互，调用其函数，或者直接向其转账。call 函数返回两个值。第一个是布尔值，用于显示函数调用是否成功。第二个是 bytes memory 类型，表示调用对方合约返回的结果。
    // 与 send 和 transfer 不同的是，call 函数可以指定 Gas。通过 call 函数，我们也可以向其他地址转账。具体的操作方法将在 call 函数的独立章节中进行详细讨论。
    // 异常可以处理
    function withdraw3() external {
        require(msg.sender == owner, "Not owner");
        (bool success, ) = msg.sender.call{value: address(this).balance, gas: 300}("");
        require(success, "Call Failed");
    }
    // 获取当前金额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}