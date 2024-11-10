// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
    多签钱包的功能: 合约有多个 owner，一笔交易发出后，需要多个 owner 确认，确认数达到最低要求数之后，才可以真正的执行。

    1、部署时候传入地址参数和需要的签名数
        - 多个 owner 地址
        - 发起交易的最低签名数
    2、有接受 ETH 主币的方法，

    3、除了存款外，其他所有方法都需要 owner 地址才可以触发

    权限检查修饰器

    4、发送前需要检测是否获得了足够的签名数

    5、使用发出的交易数量值作为签名的凭据 ID（类似上么）

    6、每次修改状态变量都需要抛出事件

    7、允许批准的交易，在没有真正执行前取消。

    8、足够数量的 approve 后，才允许真正执行。
*/
contract MultiSigWallet {
    // 多个owners地址
    address[] public owners;
    // 是否owners
    mapping(address => bool) public isOwner;
    // 需要的签名数，构造的时候设置，故用immutable类型
    uint256 public immutable required;
    // 交易的详细信息
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool exected;
    }
    // 所有提交的交易记录
    Transaction[] public transactions;
    // 每笔交易下每个owner的批准情况
    mapping(uint256 => mapping(address => bool)) public approved;
    // 存款事件
    event Deposit(address indexed sender, uint256 amount);
    // 提交交易事件
    event Submit(uint256 indexed txId);
    // 批准交易事件
    event Approve(address indexed owner, uint256 indexed txId);
    // 撤回批准交易事件
    event Revoke(address indexed owner, uint256 indexed txId);
    // 交易执行事件
    event Execute(uint256 indexed txId);

    //接收以太币的函数 允许合约接收以太币，并记录存款事件。
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // 权限检查修饰器
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }
    // 交易存在检查修饰器
    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx doesn't exist");
        _;
    }
    // 交易未批准检查修饰器
    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "tx already approved");
        _;
    }
    // 交易未执行检查修饰器
    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].exected, "tx is exected");
        _;
    }

    // 部署设置：多个owner地址、需要的签名数
    constructor(address[] memory _owners, uint256 _required) {
        // 数组为空检查
        require(_owners.length > 0, "owner required");
        // 参赛非法检查
        require(
            _required > 0 && _required <= _owners.length,
            "invalid required number of owners"
        );
        // 保存地址信息
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            // 地址非空检查
            require(owner != address(0), "invalid owner");
            // 重复检查
            require(!isOwner[owner], "owner is not unique"); // 如果重复会抛出错误
            // 保存记录
            isOwner[owner] = true;
            // 保存地址
            owners.push(owner);
        }
        required = _required;
    }

    // 获取当前余额
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    // 提交：必须是onwer
    // 返回交易ID
    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns(uint256){
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, exected: false})
        );
        emit Submit(transactions.length - 1);
        return transactions.length - 1;
    }
    // 批准：必须是onwer、此交易存在、此用户未批准、此用户未交易
    // 记录该交易的此用户的交易记录
    // 记录批准事件
    function approv(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        emit Approve(msg.sender, _txId);
    }
    // 执行：必须是onwer、此交易存在、此用户未交易
    // 满足条件开始转账
    // 记录执行日志
    function execute(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        // 检查批准的数量（必须不小于需要的签名数）
        require(getApprovalCount(_txId) >= required, "approvals < required");
        Transaction storage transaction = transactions[_txId];
        // 设置执行状态
        transaction.exected = true;
        // 调用call开转账
        (bool sucess, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        // 检查call结果
        require(sucess, "tx failed");
        emit Execute(_txId);
    }
    // 获取所有owner中已经批准的数量
    function getApprovalCount(uint256 _txId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 index = 0; index < owners.length; index++) {
            if (approved[_txId][owners[index]]) {
                count += 1;
            }
        }
    }
    // 撤回批准
    // 必须是onwer、此交易存在、此用户未交易
    // 记录撤回批准日志
    function revoke(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
        notExecuted(_txId)
    {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }
}