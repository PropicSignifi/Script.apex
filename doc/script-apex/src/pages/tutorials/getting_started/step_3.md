---
title: "Evaluating with Context"
description: "Evaluating with Context"
buttonTitle: "Done"
parentId: "getting_started"
layout: "tutorial"
time: 90
weight: 3
---

## {$page.title}

Pass the context in and we can evaluate using the variables inside.

```javascript
Map<String, Object> context = new Map<String, Object>{
    'list' => new List<String>{ 'a' },
    'map' => new Map<String, String>{ 'name' => 'b'}
};
Object result = ScriptEngine.getInstance().eval('list[0] + map.name', context);
```
