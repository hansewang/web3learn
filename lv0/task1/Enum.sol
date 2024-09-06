// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Enum {
    // 表示交易的枚举状态
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }

    // 默认值是枚举的第一个："Pending"
    Status public status;

    // 返回的是 uint类型
    // Pending  - 0
    // Shipped  - 1
    // Accepted - 2
    // Rejected - 3
    // Canceled - 4
    function get() public view returns (Status) {
        return status;
    }

    // 你能通过传uint赋值
    function set(Status _status) public {
        status = _status;
    }

    // 使用.访问枚举类型的某个枚举值
    function cancel() public {
        status = Status.Canceled;
    }

    //删除操作重置枚举到默认值 也就是第一个值0
    function reset() public {
        delete status;
    }
}