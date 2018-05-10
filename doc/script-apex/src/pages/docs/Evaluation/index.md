---
title: "Evaluation"
description: "Evaluation"
layout: "guide"
icon: "flash"
weight: 1
---

###### {$page.description}

<article id="1">

## Simple Evaluation

Simple expressions can be passed directly to evaluate them.

```javascript
Object result = ScriptEngine.getInstance().eval('1 + 2 * (3 - 1)');
```

</article>

<article id="2">

## Context Evaluation

We can also pass in a context with variables to evaluate the expression.

```javascript
Map<String, Object> context = new Map<String, Object>{
    'a' => 1,
    'b' => 2
};
Object result = ScriptEngine.getInstance().eval('a + b', context);
```

</article>

<article id="3">

## Limitations

Assignment expressions and function invocations are not supported in evaluation of JavaScript expressions.

</article>
