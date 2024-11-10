// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// WETH 是包装 ETH 主币，作为 ERC20 的合约。 标准的 ERC20 合约包括如下几个

// 3 个查询
// balanceOf: 查询指定地址的 Token 数量
// allowance: 查询指定地址对另外一个地址的剩余授权额度
// totalSupply: 查询当前合约的 Token 总量
// 2 个交易
// transfer: 从当前调用者地址发送指定数量的 Token 到指定地址。
// 这是一个写入方法，所以还会抛出一个 Transfer 事件。
// transferFrom: 当向另外一个合约地址存款时，对方合约必须调用 transferFrom 才可以把 Token 拿到它自己的合约中。
// 2 个事件
// Transfer
// Approval
// 1 个授权
// approve: 授权指定地址可以操作调用者的最大 Token 数量。

contract WETH {
    // 代币名称
    string public name = "Wrapped Ether";
    // 代币符号
    string public symbol = "WETH";
    // 代币小数位数
    uint8 public decimals = 18;

    // 委托事件
    event Approval(address indexed src, address indexed delegateAds, uint256 amount);
    // 转移事件
    event Transfer(address indexed src, address indexed toAds, uint256 amount);
    // 存款事件
    event Deposit(address indexed toAds, uint256 amount);
    // 提取事件
    event Withdraw(address indexed src, uint256 amount);

    // 地址对应资产 
    mapping(address => uint256) public balanceOf;
    // 指定地址到另一个地址的授权额度
    mapping(address => mapping(address => uint256)) public allowance;

    // 存入
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // 转出 
    function withdraw(uint256 amount) public {
        require(balanceOf[msg.sender] >= amount);
        balanceOf[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    // 当前资产总额
    function totalSupply() public view returns (uint256) {
        return address(this).balance;
    }

    // 设置委托操作的最大量
    // A账号 委托 B账号 转账  approve(b,100）
    // 授权指定地址最大操作Token总量
    function approve(address delegateAds, uint256 amount) public returns (bool) {
        allowance[msg.sender][delegateAds] = amount;
        emit Approval(msg.sender, delegateAds, amount);
        return true;
    }

    // 从当前调用者地址发送指定数量的 Token 到指定地址。
    function transfer(address toAds, uint256 amount) public returns (bool) {
        return transferFrom(msg.sender, toAds, amount);
    }

    // 委托操作
    // B账号发起 transferFrom(a, c, 100)
    // 从一个地址到另一个地址
    function transferFrom(
        address src,
        address toAds,
        uint256 amount
    ) public returns (bool) {
        require(balanceOf[src] >= amount);
        //如果 src 和 msg.sender 不同，表示 msg.sender 是代替 src 执行转账的，可能是通过 approve 函数获得的授权。
        if (src != msg.sender) {
            require(allowance[src][msg.sender] >= amount);
            allowance[src][msg.sender] -= amount;
        }
        balanceOf[src] -= amount;
        balanceOf[toAds] += amount;
        emit Transfer(src, toAds, amount);
        return true;
    }
    fallback() external payable {
        deposit();
    }
    receive() external payable {
        deposit();
    }
}