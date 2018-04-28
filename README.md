# Script.apex
Script.apex help you run JavaScript code in Apex. Basically, it compiles JavaScript code into semantic nodes, which are then evaluated in native Apex. The JavaScript expression parser in Script.apex is porting from [jsep](http://jsep.from.so/).

## Features
- Parse JavaScript code into semantic nodes
- Evaluate nodes in Apex
- Parsed nodes are cached to improve performance

## Usage

Here is how we evaluate arithmatic expressions.
```java
Object result = ScriptEngine.getInstance().eval('1 + 2 * (3 - 1)');
```

Or we can evaluate expressions consuming variables like this:
```java
Map<String, Object> context = new Map<String, Object>{
    'a' => 1,
    'b' => 2
};
Object result = ScriptEngine.getInstance().eval('a + b', context);
```

Or we can parse the nodes first, and the evaluate them:
```java
Jsep.Node node = new Jsep('1 + 2').parse();
Object result = ScriptEngine.getInstance().eval(node);
```

## Supported Operations

Supported Unary Operator

| Name | Description |
| ---- | ----------- |
| - | Negate number |
| ! | Negate boolean |
| ++ | Only prefix supported |
| -- | Only prefix supported |

Supported Logical Operator

| Name | Description |
| ---- | ----------- |
| && | Logical and |
| \|\| | Logical or |

Supported Binary Operator

| Name | Description |
| ---- | ----------- |
| == | Apex == |
| != | Apex != |
| === | Apex == |
| !== | Apex != |
| < | Apex < |
| > | Apex > |
| <= | Apex <= |
| >= | Apex >= |
| + | Apex + |
| - | Apex - |
| * | Apex * |
| / | Apex / |
| % | Apex Math.mod |

Supported Structure

| Name | Description |
| ---- | ----------- |
| Conditional Expression(? :) | Yes |
| Array Literal | Yes |
| Object Literal | Yes |

For example,
```java
ScriptEngine.getInstance.eval('["a", "b"]'); // Array literal

ScriptEngine.getInstance.eval('{ "name": "test", age: 18 }'); // Object literal
```

## Todos

### Assignment Expression Evaluation
Assignment expressions can be parsed, but cannot be evaluated yet.

### Function Invocation
Functions(methods) can be parsed now, but invocation is not implemented yet.
