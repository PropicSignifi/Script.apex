---
title: "Parsing"
description: "Parsing"
layout: "guide"
icon: "code-file"
weight: 2
---

###### {$page.description}

<article id="1">

## Parsing Expression

Here is how we can parse JavaScript expressions.

```javascript
Jsep.Node node = new Jsep('1 + 2').parse();
```

</article>

<article id="2">

## Expression Support

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

```javascript
ScriptEngine.getInstance.eval('["a", "b"]'); // Array literal

ScriptEngine.getInstance.eval('{ "name": "test", age: 18 }'); // Object literal
```

</article>
