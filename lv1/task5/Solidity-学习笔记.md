## 一、Solidity编码规范
当使用 CapWords 规范（首字母大写）的缩略语时，缩略语应全部大写，比如 HTTPServerError 比 HttpServerError 更易理解。
###### 避免的命名方式
- l（小写字母 el）
- O（大写字母 oh）
- I（大写字母 eye）
永远不要用‘l’（小写字母 el）、‘O’（大写字母 oh）或‘I’（大写字母 eye）作为单字符的变量名。在某些字体中，这些字符难以与数字 1 和 0 区分。尽量在使用‘l’时用‘L’代替。
###### 合约及库的命名
合约和库应该使用 CapWords 规范命名（首字母大写）。
###### 事件命名
事件应该使用 CapWords 规范命名（首字母大写）。
###### 函数命名
函数名使用大小写混合。
###### 函数参数命名
当定义一个在自定义结构体上的库函数时，结构体的名称必须具有自解释能力。
###### 局部变量命名
局部变量名使用大小写混合。
###### 常量命名
常量全部使用大写字母并用下划线分隔。
###### 修饰符命名
功能修饰符使用小写字符并用下划线分隔。
###### 避免冲突
当与内置或者保留名称冲突时，建议在名称末尾加单个下划线，以避免冲突。

##  二、Solidity编码规范、高级特性
### 1 数据类型
##### 1、变量
###### 数据类型
- **值类型**
	- 布尔类型
	- 整型
		- int
		- int8,int16,int32,int64,
		- int256(8的倍数)
		- uint
		- uint8 - uint256(8的倍数)
	- 静态浮点型
		- fixedM * N
		- ufixedM * N
	- 地址类型
	- 静态字节数组
		- bytes1 - bytes32
	- 枚举类型
	- 自定义类型
	- 字面值
		- 地址字面值
		- 有理数和整数字面值
		- 字符串字面值
		- Unicode字面值
- **引用类型**
	- 数组
		- 固定长度数组： T[k]
		- 动态数组 ： T[ ]
		- 特殊数组
			- bytes
			- string
	- 结构体
	- 映射类型


传递数据地址的方法通常被称为「引用传递」（pass by reference）。在这种方法中，赋值或参数传递时传递的是数据的地址，而不是数据本身。

**所有引用类型是否总是通过引用传递呢？**
答案是：并不是。引用类型数据是通过「值传递」还是「引用传递」，这实际上取决于一个重要的因素「数据位置修饰符」。
#### 2、数据位置
Solidity 中有三种数据存储位置，分别指定变量的存储方式：
- **storage**：数据永久存储在区块链上，其生命周期与合约本身一致。
- **memory**：数据暂时存储在内存中，是易失的，其生命周期仅限于函数调用期间。
- **calldata**：类似于 memory，但用于存放函数参数，与 memory 不同的是，calldata 中的数据不可修改且相比 memory 更节省 gas。 storage 可以类比为硬盘，而 memory 可类比为 RAM。calldata 可能稍显陌生，它的独特之处在于其不可变性和高效的 gas 使用。因其特性，当引用类型的函数参数不需要修改时，推荐使用 calldata 而非 memory。 为了避免过度复杂化，我们将在「Solidity进阶」中更深入地讨论 calldata 与 memory 的差异。目前，只需了解上述关于 calldata 的基本差异即可：仅用于函数参数，数据不可更改，是易失的，并且比 memory 更节约 gas。这些理解将帮助你更有效地使用Solidity中的数据位置。
#### 3、地址类型
Solidity 的地址类型用关键字 `address` 表示。它占据 20 字节（160 位），默认值为 `0x0`，表示空地址。地址类型可以细分为两种：
- **address**：普通地址类型（不可接收转账）
- **address payable**：可收款地址类型（可接收转账）
为什么要区分
1. **安全性**：通过区分这两种类型，Solidity 提供了一种额外的安全层。如果你的合约不需要发送或接收以太币，那么使用 `address` 类型可以减少意外发送或丢失以太币的风险。
2. **明确意图**：使用 `address payable` 明确表明你的合约或变量需要处理以太币的发送和接收，这有助于其他开发者理解代码的意图，并确保合约的安全性。
3. **类型安全**：Solidity 强制区分这两种类型，以防止开发者在不需要处理以太币的情况下不小心使用涉及以太币的操作，这可以减少因类型错误导致的错误和安全漏洞。
4. **优化**：在以太坊虚拟机（EVM）中，处理 `address payable` 类型的数据可能需要额外的存储空间和操作，因为它们需要支持以太币的发送和接收。通过区分这两种类型，Solidity 允许编译器和 EVM 在不需要处理以太币时进行优化。
##### transfer 和 send 应该使用哪一个
- 在转账时，应该选择使用 `transfer` 还是 `send` 呢？一般而言，我们建议一律选择 `transfer`。因为 `transfer` 是对 `send` 的改进，其目的是在转账失败时立即终止交易。相比之下，使用 `send` 时需要检查返回值以确认转账是否成功，再进行后续处理。如果忽略了这个检查，可能会导致合约受到攻击的风险。然而，根据最新的分析（截至 2023 年 1 月），这两个函数都被认为存在安全性问题，因此不建议继续使用。**更为安全的方法是使用 `call` 函数进行转账。**
- 函数 call() 可以调用其他合约中的函数
- 函数 delegatecall() 与 call() 类似，但使用当前合约的上下文来调用其他合约中的函数。
- 函数 staticcall() 也类似于 call()，但不允许改变状态变量的操作
- 函数 transfer() 和 send() 只能在 address payable 类型中使用。
#### 4、静态字节数组
1. 静态字节数组是固定长度的字节数组，属于值类型，变量储存的是数值而非数据地址。
2. Solidity 共有 32 种静态字节数组，如 bytes1、bytes2、bytes3，依次类推，最大为 bytes32。
3. 通过 [] 运算符可访问静态字节数组的特定元素，但需注意避免越界访问。
#### 5、字面值类型
- 在 Solidity 中不支持 8 进制字面值，因此不应使用 8 进制表示方式。有时你会看到一些合约中的整数字面值带有下划线 `_`，它们仅用作视觉辅助，不会影响数值。例如，1000_000 表示 100 万。
- 值得一提的是，所有的有理数和整数字面值在 Solidity 中可以是任意精度，不会有精度损失的问题。
- 然而，要注意一个规则：一旦字面值和非字面值进行了运算，字面值就会被尝试转换成非字面值的类型（转换过程中如果类型不匹配，编译器会报错）。
```
uint128 a = 1;
uint128 b = 2.5 + a + 0.5; _//编译报错_
```
- 字符串字面值用单引号 `’’` 或者双引号 `””` 定义。与 C 语言不同，Solidity 的字符串字面值后面不会跟着\0。举例来说，"foo"是三个字节，而不是四个字节。
```
string memory s1 = "This is a string"; _// 双引号_
string memory s2 = 'This is a string'; _// 单引号_
```
- 字符串字面值可以隐式地转换成 bytes1, bytes2, …, bytes32 还有 string 类型。因此，你可以直接对它们进行赋值。如下所示：
```
bytes1 b1 = "b";
bytes2 b2 = "b2";
bytes3 b3 = "b3";
bytes32 b32 = "b32";
string memory str = "string";
```
- 除此之外，字符串字面值还支持下列转义字符：
```
	`\<newline>` (字符串字面值可以横跨多行)
	`\\` (反斜杠)
	`\'` (单引号)
	`\"` (双引号)
	`\n` (新行)
	`\r` (回车)
	`\t` (tab)
	`\xNN` (十六进制表示字符)
	`\uNNNN` (unicode 表示字符)
这些转义字符可以和其他字符混合使用，例如 `”\’hello world\’”` 。
```
- Unicode 字面值和字符串字面值类似，只需要在前面加上 unicode 关键字，你就可以在里面包含任何的 UTF-8 字符。Unicode 字面值是由反斜杠 \ 和四位十六进制数拼成的。例如，\u0041 表示大写字母 A。同时，你也可以使用 Emoji：
```
string memory a = unicode"Hello \u0041 😃";
```
#### 6、枚举类型
- Solidity 的枚举类型与 C 语言中的相似，都是一种特殊的整型。它定义了一组名称和整数值之间的对应关系，内部表示为从 0 开始的正整数。
```
// 定义枚举值类型
enum ActionChoices { 
    GoLeft,     _// 底层表示为 0 _
    GoRight,    _// 底层表示为 1_
    GoUp,       _// 底层表示为 2_
    GoDown      _// 底层表示为 3_
}
// 获取枚举类型的最大最小值
type(ActionChoices).max; _// ActionChoices.GoDown ，也就是3_
type(ActionChoices).min; _// ActionChoices.GoLeft ， 也就是0_
```
- 枚举类型作为函数参数或返回值
	- 如果枚举类型仅在当前合约中定义，那么外部合约在调用当前合约时得到的枚举类型返回值会被编译器自动转换成 uint8 类型。因此，外部合约看到的枚举类型实际上是 uint8 类型。这是因为 ABI（应用二进制接口）中不存在枚举类型，只有整型，所以编译器会自动进行这种转换。

#### 7、自定义值类型
- 类似于别名，但并不等同于别名。别名与原类型完全相同，只是名称不同。然而，"自定义值类型"则不具备原始类型的操作符，其主要价值在于提高类型安全性和代码可读性。
```
// 定义
type Weight is uint128;
type Price  is uint128;
// 类型转换(没有隐式类型转换,需要使用强制类型转换进行转换。)
Weight w = Weight.wrap(10); // 将原生类型转换成自定义值类型
Price  p = Price.wrap(5);   // 将自定义值类型转换成原生类型。
// Weight 和 Price 是不同的类型，不能进行算术运算
Weight wp = w+p; _//编译错误_
Price  pw = p+w; _//编译错误_
// 不会继承原生类型的操作符，包括 + - * / 等, 编译器将报错："TypeError: Operator + not compatible with types UserDefinedValueType.Weight and UserDefinedValueType.Weight."
Weight sum = w1+w2; _// 编译器报错_
// 需要自定义函数来代替操作符
function add(Weight lhs, Weight rhs) public pure returns(Weight) {
  return Weight.wrap(Weight.unwrap(lhs) + Weight.unwrap(rhs));
}
```
#### 8、静态数组
-  零值初始化
```
// 若你只声明了静态数组但未手动进行初始化，那么数组中的所有元素都会被零值初始化。这意味着所有元素都会被赋予默认值。
uint[3] memory nftArr; _//所有元素都是0_
```
-  数组字面值初始化 ,
	- 需要注意的是，数组字面值的基础类型是由其第一个元素的类型确定的。
	- 另外需要注意的一点是，定义的数组长度必须与数组字面值的长度相匹配，否则会导致编译错误。
```
_//必须使用uint(1000)显式地将「数组字面值」第一个元素的类型转换成uint_
uint[3] memory nftArr = [uint(1000), 1001, 1002];
uint[3] memory nftArr = [uint(1000), 1001];  _//编译错误，长度不匹配_
```
#### 9、动态数组
- 零值初始化
- 使用 `new` 关键字可以在任何数据位置创建动态数组。
```
// 初始化,它的所有元素值会被「零值初始化」
uint n = 3;
uint[] memory nftArr = new uint[](n);
```
- 如果你的动态数组是在 storage 中声明的，你也可以使用数组字面值来初始化：
```
uint[] storageArr = [uint(1), 2]; _// 动态数组只有在storage位置才能用数组字面值初始化_
```
#### 10、数组切片
- 数组切片（array slice）是建立在数组基础上的一种视图（view）。其语法形式为 arr[start:end]。这个视图包含的是从索引 start 到索引 end-1 的元素。与数组不同的是，切片是没有具体类型的，也不会占据存储空间。它是一种方便我们处理数据的抽象方式。
- 数组切片只能作用于 calldata
```
- 1、数组切片截取字符串前 4BYTES
// 如果输入"abcdef"，将会输出"abcd"_
function extracFourBytes(string calldata payload) public view {
    string memory leading4Bytes = string(payload[:4]);
    console.log("leading 4 bytes: %s", leading4Bytes);
}
- 2、目前只能对 calldata 使用数组切片。memory 和 storage 都不可以使用。在 Solidity 中，仅能对 calldata 进行数组切片操作。若尝试在 memory 或 storage 中使用，编译将会报错。由于 calldata 数据不可更改，因此无法对数组切片的值进行修改。
uint[5] storageArr = [uint(0), 1, 2, 3, 4];
function foo() public {
    uint[3] storage s1 = storageArr[1:4]; _// 编译错误，不能对 storage 位置的数组进行切片_

    uint[5] memory memArr = [uint(0), 1, 2, 3, 4];
    uint[3] memory s2 = memArr[1:4]; _// 编译错误，不能对 memory 位置的数组进行切片_
}
```

#### 11、数组成员
数组是一种组合数据类型，它包含若干成员变量和成员函数。
###### 数组的长度（成员变量length）
无论是静态还是动态，都具有一个成员变量：`length`。这个成员变量记录了数组的长度。我们可以通过点操作符（`.`）来访问这个值：
```
uint[3] memory arr1 = [uint(1000), 1001, 1002];
uint[] memory arr2 = new uint[](3);
uint arr1Len = arr1.length; _// 3_
uint arr2Len = arr2.length; _// 3_
```
###### 动态数组成员函数
只有当动态数组位于存储（storage）位置时，它才具备成员函数。与此相对，静态数组以及位于 calldata 或 memory 中的动态数组不具备任何成员函数。这些成员函数可以改变数组的长度，具体包括：
- `push()`：在数组末尾增加一个元素，并赋予零值，使得数组长度增加一。
- `push(x)`：将元素 x 添加到数组末尾，同样使数组长度增加一。
- `pop()`：从数组末尾移除一个元素，导致数组长度减少一。
```
uint[] arr; _//定义在storage位置的数组_
function pushPop() public {
    _// 刚开始没有任何元素_
    arr.push(); _// 数组有一个元素：[0]_
    arr.push(1000); _//数组有两个元素：[0, 1000]_
    arr.pop(); _// 数组剩下一个元素： [0]_
}
// 编译错误：静态数组或非 storage 动态数组不能使用 `push` 或 `pop` 成员函数。
uint[3] memory arr;
arr.push(1); _//编译错误，只有 storage 上的动态数组才能调用 push 函数_
arr.pop(); _// 编译错误，只有 storage 上的动态数组才能调用 pop 函数_

// 编译错误：数据位置不在 `storage` 的动态数组使用 `push` ， `pop` 成员函数
uint[] memory arr = new uint[](3);
arr.push(1); _//编译错误，只有 storage 上的动态数组才能调用 push 函数_
arr.pop(); _// 编译错误，只有 storage 上的动态数组才能调用 pop 函数_
```
#### 12、多维数组
- **静态多维数组**、**动态多维数组**。
- Solidity 在声明多维数组时，"行"和"列"的顺序与 C 语言、JavaScript 等其他语言相反。在 C 语言和 JavaScript 中，声明一个 5 行 3 列的多维数组的格式应该是 `uint[5][3]`。这一点需要特别注意，尤其是在遍历多维数组时，**很容易将行列搞反**。
![](photo/Pasted%20image%2020241102181254.png)
```
// 静态多维数组的声明格式如下
T[col][row] DataLocation arrName;
// 动态多维数组的声明格式如下
T[][] DataLocation arrName;
```
- 其他特性跟同一维数组
#### 13、动态字节数组
###### 动态字节数组与静态字节数组有几点区别：
1. 长度的确定性：静态字节数组的长度在编译时就已经固定，不可更改；而动态字节数组的长度则是可变的，可以根据需求调整。
2. 长度限制：静态字节数组的长度范围为 1 至 32 字节，这是一个硬性的限制；相对地，动态字节数组则没有这样的长度限制。
3. 数据类型：**动态字节数组是引用类型**，即它们在内存中存储的是数组地址；而**静态字节数组则是值类型**，直接在内存中存储数据。
###### 两种动态字节数组类型：`bytes` 和 `string`
- `bytes` 类型类似于一个 `bytes1[]` 数组，但其在内存（memory）和调用数据（calldata）中的存储更为紧凑。在 Solidity 的存储规则中，如 `bytes1[]` 这样的数组会要求每个元素占据 32 字节的空间或其倍数，不足 32 字节的部分会通过自动填充（padding）补齐至 32 字节。然而，对于 `bytes` 和 `string` 类型，这种自动填充的要求并不存在，使得这两种类型在存储时能更加节省空间。
- `string` 类型在内部结构上与 `bytes` 类型基本相同，但它不支持下标访问和长度查询。换言之，尽管 `string` 和 `bytes` 在存储结构上一致，它们提供的接口却有所不同，以适应不同的用途。
- 总结来说，`bytes` 和 `string` 提供了在动态数据处理上更高的存储效率，尤其适合于处理大量数据的场景，而避免了不必要的内存浪费。
```
// `bytes` 转 `string`
bytes memory bstr = new bytes(10);
string memory message = string(bstr); _// 使用string()函数转换_
// `string` 转 `bytes`
string memory message = "hello world";
bytes memory bstr = bytes(message); _//使用bytes()函数转换_
```
- string 不能进行下标访问，也不能获取长度 在 Solidity 中，
```
- 虽然 `string` 类型在本质上是一个字符数组，但它目前不支持下标访问和获取长度的操作。这意味着与其他数组类型不同，您不能通过索引来访问 `string` 中的单个字符，也无法直接查询 `string` 的长度。这些限制要求开发者在处理字符串数据时采用不同的方法或转换为更灵活的数据类型如 `bytes`，以进行更复杂的操作。

string str = "hello world";
uint len = str.length; _// 不合法，不能获取长度_
bytes1 b = str[0]; _// 不合法，不能进行下标访问_
```
- 你可以将 `string` 转换成 `bytes` 后再进行下标访问和获取长度
```
string str = "hello world";
uint len = bytes(str).length; _// 合法_
bytes1 b = bytes(str)[0]; _// 合法_
```
#### 14、结构体
- 结构体则是将不同类型的元素绑定在一起，创建出一种复合类型。
- 结构体在 Solidity 中的应用非常广泛，具体体现在以下几个方面：
	1. 数据管理：结构体能够将多种不同类型的数据组合在一起，便于进行统一管理。
	2. 函数参数处理：通过结构体，我们可以将多个数据作为一个整体传入函数，无需将其拆解为多个独立参数。
	3. 返回值管理：同样地，结构体也可以用来从函数返回多个值，简化数据处理。
	4. 增强表达力：结构体的使用增强了 Solidity 的编程表达能力，因为结构体可以与其他结构体、数组或映射类型进行嵌套，从而使得代码结构更加清晰，易于理解。
- 定义结构体类型, 需要使用 `struct` 关键字
```
struct Book {
    string title; _// 书名_
    uint price;   _// 价格_
}
```
- 结构体声明
在 Solidity 中，声明结构体变量时，与其他引用类型一样，需要指定数据的存储位置。如我们之前在“数据位置”一节中所讨论的，每个引用类型的变量声明都必须明确其数据位置修饰符，除非这是一个状态变量的声明，此时可以省略数据位置修饰符。
```
// 声明结构体类型变量
Book memory book;

// 根据上面的例子，我们不难总结出声明一个结构体的格式如下：
StructName DataLocation varName;
```
- 初始化结构体有两种常见方法。
	-  其中一种是通过键值对的形式，明确指定每个成员的初始值。这种方式为结构体的每个字段赋予明确的值，确保初始化过程清晰且易于理解。下面是一个示例：
	- 依据定义结构体时各个成员的顺序一一给定初始化值，不能省略任何一个成员。
```
Book memory book1 = Book(
    {
        title: "my book title",
        price: 25
    }
);

Book memory book2 = Book("my book title", 25);
```
#### 15、映射类型
- 映射的底层实现使用了类似哈希表（HashTable）的数据结构。
- 映射类型变量的声明
```
mapping(KeyType => ValueType) varName;
```
- 键的类型（KeyType）必须是内置的值类型，如 `uint`、`string`、`bytes` 等。重要的是要注意，键不能是数组、结构体或其他映射类型等引用类型。
- 值的类型（ValueType）则可以是任意类型，包括数组、结构体等。此外，变量名（varName）可以由开发者自由命名，以符合具体的应用需求。
```
// 映射类型记录空投数额
mapping(address => uint) airDrop;
```
- 映射类型**仅能声明在 `storage`** 。声明在其他数据位置都会报错。
```
mapping(address => uint) memory myMap; _// 编译错误_
```
- 映射类型**作为入参和返回值时，函数可见性必须是 private 或 internal**
```
函数的可见性（visibility）决定了函数可以在哪些上下文中被调用。关于映射类型在函数参数和返回值中的使用，有特定的规则依据函数的可见性不同而变化：
- 当函数的可见性设置为 `public` 或 `external` 时，你不能在函数的参数（入参）或返回值中使用映射类型。
- 如果函数的可见性是 `private` 或 `internal`，则允许在入参和返回值中使用映射类型。

_// 编译错误，映射类型作为入参和返回值时，函数可见性必须是 private 或 internal_
function invalidDeclaration(mapping(address => uint) storage myMap) public {} 

_// 编译错误，映射类型作为入参和返回值时，函数可见性必须是 private 或 internal_
function invalidDeclaration(mapping(address => uint) storage myMap) external {}

_// 合法_
function validDeclaration(mapping(address => uint) storage myMap) private {} 

_// 合法_
function validDeclaration(mapping(address => uint) storage myMap) internal {}
```
- **无 `length` 属性**：与数组不同，映射类型没有内置的 `length` 属性，这意味着你不能直接查询映射中元素的数量。
- **无法直接遍历**：映射类型不能直接进行遍历，因为它们不存储键的列表或顺序。
### 2    控制结构
#### 1、可见性
为了增强合约的安全性，Solidity 提供了一套机制来限制合约中变量和函数的访问范围。
###### 变量的可见性修饰符
- `public`：变量可以被当前合约内部以及外部访问。对于 `public` 变量，Solidity 自动创建一个访问器函数，允许外部合约也可以读取这些变量。
- `private`：变量只能被定义它的合约内部访问。即使是派生合约也无法访问 `private` 变量。
- `internal`：变量可以被当前合约以及所有派生自该合约的“子合约”访问，但不能被外部合约直接访问。
###### 函数的可见性修饰符
- `public`：函数可以在当前合约内部和外部被访问。这是函数默认的可见性级别，如果没有指定其他修饰符。
- `external`：函数只能从合约外部被调用。这种修饰符通常用于那些不需要在合约内部调用的函数，可优化 gas 消耗。
- `private`：函数仅限于在定义它的那个合约内部被调用，不可在任何外部合约或派生合约中访问。
- `internal`：函数可以在定义它的合约内部以及所有派生自该合约的子合约中被调用，但不能从外部合约调用。
###### 合约分类
1. 主合约（当前合约内部）：这是正在被我们讨论或编写的合约本身。在主合约内部，所有成员（变量和函数）通常都是可访问的，除非它们被标记为 `private`。
2. 子合约（继承自当前合约的合约）：这些合约是从主合约派生出来的。子合约可以访问主合约中标记为 `internal` 或更宽松访问级别的成员，但不能访问 `private` 成员。
3. 第三方合约（外部合约）：这类合约与当前合约没有继承关系。它们只能访问当前合约中标记为 `public` 或 `external` 的成员。

`简单来说，子合约是从主合约继承而来的，它们共享某些特性和行为。而第三方合约则与主合约及子合约没有任何继承关系，可以看作是完全独立的实体。如果将主合约和子合约比作一个家庭的成员，那么第三方合约就像是外面的陌生人。`
`重要的是要理解，我们所讨论的访问限制都是从主合约（当前合约）的视角出发的。这意味着，当我们编写主合约时，使用的可见性修饰符决定了哪些外部实体（子合约或第三方合约）可以访问主合约中的哪些变量和函数。这样的设置帮助合约开发者确保数据安全，同时允许一定程度上的灵活性和扩展性。`
###### 主合约
主合约其实就是一个普通合约，内部定义了很多变量和函数。这些变量和函数可能有不同的可见性。主合约可以访问自己内部可见性为 `private` , `internal` , `public` 的任何变量和函数。
```
_// 主合约可以访问自己内部可见性为 private, internal, public 的变量和函数_
contract MainContract {
    uint varPrivate;
    uint varInternal;
    uint varPublic;

    function funcPrivate() private {}
    function funcInternal() internal {}
    function funcExternal() external {}
    function funcPublic() public {}
}
```
###### 子合约
子合约继承了主合约。继承的语法是 `Child is Parent` 。关于继承有关的详细介绍，我们会在 「Solidity 进阶」进行介绍。子合约允许访问主合约中可见性为 `internal` ， `public` 的函数。
```
contract ChildContract is MainContract {
    function funcChild() private {
        funcInternal(); _// 子合约可以访问主合约中可见性为internal，public的函数_
        funcPublic(); _// 子合约可以访问主合约中可见性为internal，public的函数_
    }
}
```
###### 第三方合约
第三方合约是一个普通合约。可以通过主合约的地址来与主合约进行交互, 其交互语法如下所示。第三方合约可以访问主合约中可见性为 `external` ， `public` 的函数
```
contract ThirdPartyContract {
      function funcThirdParty(address mainContractAddress) private {
            MainContract(mainContractAddress).funcExternal(); _// 第三方合约可以访问主合约中可见性为external，public的函数_
            MainContract(mainContractAddress).funcPublic(); _// 第三方合约可以访问主合约中可见性为external，public的函数_
      }
}
```
###### 可见性对于合约访问的限制
可见性就是合约变量和函数的可访问性
- public
可见性为 **`public` 的变量和函数**可以**被任何合约访问**。也就是可以被 `MainContract` , `ChildContract` , `ThirdPartyContract` 访问。
- external
可见性为 **`external` 的函数**只能**被第三方合约访问**。也就是只能被 `ThirdPartyContract` 访问。注意**变量是没有 `external` 修饰符**的。
- internal
可见性为 **`internal` 的变量和函数**可以**被主合约和子合约访问**。也就是可以被 `MainContract` , `ChildContract` 访问。
#### 2、状态可变性
正确使用这些修饰符不仅能提高合约的安全性和可读性，还有助于 Debug 过程，因为它们确保函数行为与开发者的意图一致。如果一个被标记为 `pure` 或 `view` 的函数尝试修改合约状态，**Solidity 编译器将抛出错误**，防止潜在的逻辑错误影响合约执行。这种机制强制开发者更加精确地规划函数的角色和行为，从而提高整个合约的稳健性和效率。
##### 状态可变性修饰符（state mutability modifiers）有3种类型，包括 `pure` 、`view`、`payable`：
- **`view`**：这种类型的函数仅能查询合约的状态，而不能对状态进行任何形式的修改。简而言之，`view` 函数是**只读**的，它们可以安全地读取合约状态但不会造成任何状态改变。
- **`pure`**：表示**最严格**的访问限制，它们**不能查询也不能修改合约状态**。这类函数只能执行一些基于其输入参数的计算并返回结果，而不依赖于合约中存储的数据。例如，一个计算两数相加的函数可以被标记为 `pure`。
- **`payable`**：允许函数接收以太币（Ether）转账。函数**默认是不接受以太币转账**的；如果你的函数需要接收转账，则必须**明确指定为 `payable`**。这是处理金融交易时必不可少的修饰符。
```
**view 函数**
如果你的函数承诺不会修改合约状态，那么你应该为它加上 `view` 修饰符。如下所示：
uint count;
function GetCount() public view returns(uint) {
	return count;
}
**pure 函数**
如果你的函数承诺不需要查询，也不需要修改合约状态，那么你应该为它加上 `pure` 修饰符。如下所示：
function add(uint lhs, uint rhs) public pure returns(uint) {
	return lhs + rhs;
}
**payable 函数**
函数默认是不能接受 Ether 转账的。如果你的函数需要接受转账，那么你应该为它加上 `payable` 修饰符。如下所示：
function deposit() external payable {
	_// deposit to current contract_
}
```
##### 怎样才算修改合约状态（8种主要行为）：
1. 修改状态变量：直接改变存储在合约中的任何状态变量的值。
2. 触发事件：在合约中发出事件，这通常用于记录合约活动，尽管本身不改变任何存储的状态变量，但被视为状态改变，因为它改变了链上的日志。
3. 创建其他合约：通过合约代码创建新合约实例。
4. 使用 `selfdestruct`：销毁当前合约，并将剩余的以太币发送到指定地址。
5. 通过函数发送以太币：包括使用 `transfer` 或 `send` 方法发送以太币。
6. 调用非 `view` 或 `pure` 的函数：调用任何可能改变状态的函数，如果函数未明确标记为 `view` 或 `pure`，则默认可能修改状态。
7. 使用低级调用：如 `call`、`delegatecall`、`staticcall` 等。这些低级函数允许与其他合约交互，并可能导致状态变化。
8. 使用含有特定操作码的内联汇编：特定的汇编代码可能直接修改状态，例如直接写入存储或执行控制合约资金的操作。
##### 怎样才算查询合约状态(5 种行为)
1. 读取状态变量：访问和读取合约中的状态变量。
2. 访问 `address(this).balance` 或 `<address>.balance`：获取当前合约或指定地址的余额。
3. 访问 `block`、`tx`、`msg` 的成员：读取区块链相关信息，如 `block.timestamp`、`tx.gasprice`、`msg.sender` 等。
4. 调用未标记为 `pure` 的任何函数：调用任何未被标记为 `pure` 的函数，即使这些函数本身也只是读取状态。
5. 使用包含某些操作码的内联汇编：使用可能会读取状态的特定汇编代码。
#### 3、receive函数
`receive` 函数是 Solidity 中的一种特殊函数，主要用于接收以太币（Ether）的转账。此外，还有一个 `fallback` 函数也可以用来接收以太币转账，我们将在下一节详细介绍。
`receive` 函数是 Solidity 中的一种特殊函数，主要用于接收以太币（Ether）的转账。此外，还有一个 `fallback` 函数也可以用来接收以太币转账，我们将在下一节详细介绍。
```
receive() external payable {
    _// 函数体_
}
```
如果一个合约既没有定义 `receive` 函数，也没有定义 `fallback` 函数，那么该合约将无法接收以太币转账。在这种情况下，所有试图向该合约进行的转账操作都会被 revert（回退）

`fallback` 函数是 Solidity 中的一种特殊函数，用于在调用的函数不存在或未定义时充当兜底。顾名思义，`fallback` 在中文中有回退、兜底的意思。类似于没有带现金时可以使用银行卡付款。需要注意的是，这里所说的“匹配不到”、“不存在”、“没有定义”都指的是同一个意思。
`fallback` 函数可以在以下两种情况下兜底：
- `receive` 函数不存在（因为没有定义）
- 普通函数不存在（因为没有定义
简而言之：
- 当需要用到 `receive` 函数时，如果它没有被定义，就使用 `fallback` 函数兜底。
- 当调用的函数在合约中不存在或没有被定义时，也使用 `fallback` 函数兜底。
## 三、合约调用与ABI
##### 1、合约之间调用
在以太坊这样的区块链平台上，智能合约之间的调用通常是通过合约地址和函数调用来实现的。以下是一种基本的合约调用方式：
1. 获取被调用合约的地址： 在调用合约中，你需要获取目标合约的地址。这通常通过在部署智能合约时获得目标合约的地址，或者通过其他途径（例如查看区块链浏览器）来获取。
2. 定义接口： 为了与目标合约进行交互，你需要在调用合约中定义一个接口，以便调用目标合约的函数。这个接口通常包括目标合约的函数签名和返回值类型。
3. 调用函数： 通过目标合约的地址和定义的接口，在调用合约中调用目标合约的函数。这可以通过调用合约的方法或者使用底层的调用指令来实现。
4. 处理返回值（可选）： 如果被调用的合约函数有返回值，调用合约可以选择处理这些返回值，以便根据需要执行后续操作。

```
// 合约B
pragma solidity ^0.8.0;
contract ContractB {
    uint256 public value;
    function setValue(uint256 _value) public {
        value = _value;
    }
    function getValue() public view returns (uint256) {
        return value;
    }
}

// 合约A
pragma solidity ^0.8.0;
// 引入合约B的ABI
import "./ContractB.sol";
contract ContractA {
    ContractB public contractB; // 合约B实例
    constructor(address _contractBAddress) {
        contractB = ContractB(_contractBAddress); // 实例化合约B
    }
    // 向合约B设置值
    function setValueInContractB(uint256 _value) public {
        contractB.setValue(_value);
    }
    // 从合约B获取值
    function getValueFromContractB() public view returns (uint256) {
        return contractB.getValue();
    }
}

在这个例子中，合约 A 实例化了合约 B，并且可以调用合约 B 中的函数。在构造函数中，合约 A 接受合约 B 的地址作为参数。然后，通过调用 setValueInContractB 和 getValueFromContractB 函数，合约 A 可以在合约 B 中设置值并获取值。
当你在以太坊上部署这两个合约，并在合约 A 中传入合约 B 的地址时，你就可以在合约 A 中成功调用合约 B 的函数了。
```
##### 2、函数的签名
一个函数调用数据的前 4 字节，指定了要调用的函数。这就是某个函数签名的 Keccak 哈希的前 4 字节（bytes32 类型是从左取值）。
函数签名被定义为基础原型的规范表达，而基础原型是**函数名称加上由括号括起来的参数类型列表，参数类型间由一个逗号分隔开，且没有空格。**.
⚠️ 注意: 函数的返回类型并不是函数签名的一部分。在 Solidity 的函数重载 中，返回值并没有被考虑。这是为了使对函数调用的解析保持上下文无关。 然而 metadata 的描述中即包含了输入也包含了输出。（参考 JSON ABI）。
##### 3、ABI 接口
在以太坊（Ethereum）生态系统中，应用程序二进制接口（Application Binary Interface，ABI）是从区块链外部与合约进行交互，以及合约与合约之间进行交互的一种标准方式。
###### 3.1 ABI编码
之前介绍以太坊交易和比特币交易的不同时提到，以太坊交易多了一个 DATA 字段，DATA 的内容会解析为对函数的消息调用，DATA 的内容其实就是 ABI 编码。
###### 3.2 函数选择器
在调用函数时，用前面 4 字节的函数选择器指定要调用的函数，函数选择器是某个函数签名（下面介绍）的 Keccak（SHA-3）哈希的前 4 字节，即： `bytes4(keccak256("count()"))`
count()的 Keccak 的 hash 结果是： `06661abdecfcab6f8e8cf2e41182a05dfd130c76cb32b448d9306aa9791f3899`，开发者可以用一个 在线 hash 的工具([https://emn178.github.io/online-tools/keccak_256.htm](https://emn178.github.io/online-tools/keccak_256.htm))验证下，取出前面 4 个字节就是 0x06661abd。
函数签名是函数名及参数类型的字符串（函数的返回类型并不是这个函数签名的一部分）。比如上文中的 count()就是函数签名，当函数有参数时，使用参数的基本类型，并且不需要变量名，因此函数 add(uint i)的签名是 add(uint256)，如果有多个参数，使用“,”隔开，并且要去掉表达式中的所有空格。因此，foo(uint a, bool b) 函数的签名是 foo(uint256,bool)，函数选择器计算则是：
`bytes4(keccak256("foo(uint256,bool)"))`
公有或外部（public /external）函数都有一个成员属性.selector 来获取函数的函数选择器。
###### 3.3 参数编码
如果一个函数带有参数，编码的第 5 字节开始是函数的参数。在前面的 Counter 合约里添加一个带参数的方法：
`function add(uint i) public { counter = counter + i; }`
###### 3.4 通过 ABI 编码调用函数
通常，在合约中调用 Counter 合约的 count() 函数的形式是：Counter.count() ，在上一章，介绍过底层调用 call 函数，因此也可以直接通过 call 函数和 ABI 编码来调用 count()函数：
```
(bool success, bytes memory returnData) = address(c).call("0x06661abd"); // c 为 Counter 合约地址，0x06661abd
require(success);
```
其中，c 为 Counter 合约地址，0x06661abd 是 count()函数的编码，如果 count()函数发生异常，call 调用会返回 fasle，因此需要检查返回值。
使用底层调用有一个好处：可以非常灵活的不同合约的不同的函数，并且在编写合约时，并不需要提前知道目标函数的合约地址及函数，例如，可以定义一个 Task 合约，它可以调用任意合约：
```
contract Task { 
	function execute(address target, uint value, bytes memory data)
	public payable returns (bytes memory) { 
		(bool success, bytes memory returnData) = target.call{value:value}(data); 
		require(success, "execute: Transaction execution reverted."); 
		return returnData; 
	} 
}
```
###### 3.5 ABI 接口描述
ABI 接口描述是由编译器编译代码之后，生成的一个对合约所有接口和事件描述的 JSON 文件。
JSON 数组中包含了 3 个函数描述，描述合约所有接口方法，
- **在合约外部（如 DAPP）调用**合约方法时，就需要利用这个描述来获得合约的方法，后面会进一步介绍 ABI JSON 的应用。
- 不过，DApp 开发人员并不需要使用 ABI 编码调用函数，**只需要提供 ABI 的接口描述 JSON 文件**，编码由 Web3 或 ether.js 库来完成。
## 四、合约工具
### 合约开发工具
#### Hardhat
- Hardhat 是一个基于 Node.js 的项目，通过安装 hardhat 包并添加 hardhat.config.js 文件来配置。使用 Hardhat 需要具备一定的 JavaScript 或 TypeScript 知识。
- Hardhat 以任务（task）为核心的开发工具，所有操作，如编译、部署、测试，都被视为一个任务。此外，社区提供了许多插件，使其功能更加强大。
#### Foundry
- Foundry 项目使用 Solidity 编写测试脚本，除了 Solidity 外，不需要其他语言基础。
- Foundry 与链上交互的能力很方便、很强大。
### 合约审计工具
#### Slither
- Slither 是一个用 Python 3 编写的智能合约静态分析框架，具备以下功能：
#### Mythril
- Mythril 是一个以太坊官方推荐的智能合约安全分析工具，使用符合执行来检测智能合约中的各种安全漏洞，在 Remix、Truffle 等 IDE 里都有集成。
#### Securify
- Securify 2.0 是以太坊智能合约的安全扫描器，由 以太坊基金会 和ChainSecurity支持。 Securify 背后的核心 研究 是在苏黎世联邦理工学院的安全、可靠和智能系统实验室进行的。

