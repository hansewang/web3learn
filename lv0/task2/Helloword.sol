// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.17;

// 简单的合约测试例子
contract HelloWorldTest {
    string storeMsg;

    function set(string memory message) public {
        storeMsg = message;
    }

    function get() public view returns (string memory) {
        return storeMsg;
    }
}