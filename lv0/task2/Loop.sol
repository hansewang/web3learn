// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// 不控制循环，因为这可能会达耗尽gas，导致你的交易失败。
contract Loop {
    function loop() public  {
        // for loop
        for (uint256 i = 0; i < 10; i++) {
            if (i == 3) {
                // Skip to next iteration with continue
                continue;
            }
            if (i == 5) {
                // Exit loop with break
                break;
            }
        }
        // while loop
        uint256 j;
        while (j < 10) {
            j++;
        }
    }
}