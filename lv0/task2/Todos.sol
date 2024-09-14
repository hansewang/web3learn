// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./StructDeclaration.sol";

// Solidity 中有三种引用类型。分别是数组，结构体和映射类型。
// 数组是把一堆类型相同的元素绑在一起，形成一种新的类型。
// 结构体是把不同类型的元素绑在一起，形成的一种新类型。

contract Todos {
    // struct Todo {
    //     string text;
    //     bool completed;
    // }

    // An array of 'Todo' structs
    // todo结构类型的动态数组
    Todo[] public todos;

    function create(string calldata _text) public {
        // 3 ways to initialize a struct
        // 三种方法初始化结构体
        // 1： calling it like a function
        // 调用函数的方式
        todos.push(Todo(_text, false));
        
        // key value mapping
        // 2： k:v 映射传值
        todos.push(Todo({text: _text, completed: false}));

        // initialize an empty struct and then update it
        Todo memory todo;
        todo.text = _text;
        // todo.completed initialized to false
        // 3： 初始一个空结构体，然后赋值某个元素
        todos.push(todo);
    }

    // Solidity automatically created a getter for 'todos' so
    // you don't actually need this function.
    function get(uint256 _index)
        public
        view
        returns (string memory text, bool completed)
    {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }

    // update text
    function updateText(uint256 _index, string calldata _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }

    // update completed
    function toggleCompleted(uint256 _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}