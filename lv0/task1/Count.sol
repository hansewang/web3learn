// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 一个计数合同的测试例子
contract Counter {
    uint256 public count;

    // 获取当前值
    function get() public view returns (uint256) {
        return count;
    }

    // 自增加1的方法
    function inc() public {
        count += 1;
    }

    // 自减1的方法
    function dec() public {
        // This function will fail if count = 0
        count -= 1;
    }
}