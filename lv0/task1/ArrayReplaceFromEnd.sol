// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 通过用最后一个元素替代要删除的元素
contract ArrayReplaceFromEnd {
    uint256[] public arr;

    function remove(uint256 index) public {
        // Move the last element into the place to delete
        arr[index] = arr[arr.length - 1];
        // Remove the last element
        arr.pop();
    }

    function test() public {
        arr = [1, 2, 3, 4];

        remove(1); //[1, 2, 3, 4] -》 [1, 4, 3, 4]  -》 [1, 4, 3]
        // [1, 4, 3]
        assert(arr.length == 3);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
        assert(arr[2] == 3);

        remove(2); // [1, 4, 3]  -》 [1, 4, 3]  -》[1, 4]
        // [1, 4]
        assert(arr.length == 2);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
    }
}