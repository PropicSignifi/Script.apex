/**
 * MIT License
 *
 * Copyright (c) 2018 Click to Cloud Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/
 //https://github.com/Click-to-Cloud/Script.apex
public virtual class ScriptEngine {
    private static final Map<String, ScriptEngine> engines = new Map<String, ScriptEngine>{
        'apex' => new ApexScriptEngine()
    };

    private static final Map<String, Jsep.Node> cache = new Map<String, Jsep.Node>();

    protected ScriptEngine() {
    }

    public static ScriptEngine getInstance() {
        return getInstance('apex');
    }

    public static ScriptEngine getInstance(String name) {
        return engines.get(name);
    }

    protected virtual Object evalIdentifier(String name, Map<String, Object> context) {
        return context.get(name);

    }

    protected virtual Object evalMember(Object target, String property, Map<String, Object> context) {
        if(target instanceof List<Object> && isInteger(property)) {
            return ((List<Object>)target).get(Integer.valueOf(property));
        }
        if(target instanceof Map<String, Object>) {
            return ((Map<String, Object>)target).get(property);
        }
        if(target instanceof String && isInteger(property)) {
            return ((String)target).split('').get(Integer.valueOf(property));
        }
        if(target instanceof SObject) {
            return ((SObject)target).get(property);
        }
        throw new EvalException('Cannot evaluate "' + property + '" of "' + String.valueOf(target) + '"');
    }

    protected virtual Object evalThis(Map<String, Object> context) {
        return context;
    }

    protected virtual Object evalCall(Object callee, List<Object> arguments, Map<String, Object> context) {
        // TODO
        return null;
    }

    public Object eval(String code) {
        return this.eval(code, null);
    }

    public Object eval(String code, Map<String, Object> context) {
        Jsep.Node node = cache.get(code);
        if(node == null) {
            node = new Jsep(code).parse();
            cache.put(code, node);
        }
        return this.eval(node, context);
    }

    public Object eval(Jsep.Node node) {
        return this.eval(node, null);
    }

    public Object eval(Jsep.Node node, Map<String, Object> context) {
        if(context == null) {
            context = new Map<String, Object>();
        }

        if(node instanceof Jsep.CompoundNode) {
            return eval((Jsep.CompoundNode)node, context);
        }
        if(node instanceof Jsep.IdentifierNode) {
            return eval((Jsep.IdentifierNode)node, context);
        }
        if(node instanceof Jsep.MemberExpressionNode) {
            return eval((Jsep.MemberExpressionNode)node, context);
        }
        if(node instanceof Jsep.LiteralNode) {
            return eval((Jsep.LiteralNode)node, context);
        }
        if(node instanceof Jsep.DatetimeNode) {
            return eval((Jsep.DatetimeNode)node, context);
        }
        if(node instanceof Jsep.DateNode) {
            return eval((Jsep.DateNode)node, context);
        }
        if(node instanceof Jsep.TimeNode) {
            return eval((Jsep.TimeNode)node, context);
        }
        if(node instanceof Jsep.ThisExpressionNode) {
            return eval((Jsep.ThisExpressionNode)node, context);
        }
        if(node instanceof Jsep.CallExpressionNode) {
            return eval((Jsep.CallExpressionNode)node, context);
        }
        if(node instanceof Jsep.UnaryExpressionNode) {
            return eval((Jsep.UnaryExpressionNode)node, context);
        }
        if(node instanceof Jsep.BinaryExpressionNode) {
            return eval((Jsep.BinaryExpressionNode)node, context);
        }
        if(node instanceof Jsep.LogicalExpressionNode) {
            return eval((Jsep.LogicalExpressionNode)node, context);
        }
        if(node instanceof Jsep.ConditionalExpressionNode) {
            return eval((Jsep.ConditionalExpressionNode)node, context);
        }
        if(node instanceof Jsep.ArrayExpressionNode) {
            return eval((Jsep.ArrayExpressionNode)node, context);
        }
        if(node instanceof Jsep.AssignmentExpressionNode) {
            return eval((Jsep.AssignmentExpressionNode)node, context);
        }
        if(node instanceof Jsep.ObjectExpressionNode) {
            return eval((Jsep.ObjectExpressionNode)node, context);
        }

        throw new EvalException('Invalid node to evaluate');
    }

    public Object eval(Jsep.CompoundNode node, Map<String, Object> context) {
        List<Object> result = new List<Object>();
        for(Jsep.Node childNode : node.body) {
            Object childResult = eval(childNode, context);
            result.add(childResult);
        }

        return result;
    }

    public Object eval(Jsep.IdentifierNode node, Map<String, Object> context) {
        return this.evalIdentifier(node.name, context);
    }

    public Object eval(Jsep.MemberExpressionNode node, Map<String, Object> context) {
        Object target = this.eval(node.target, context);
        String property = null;
        if(node.computed) {
            property = String.valueOf(this.eval(node.property, context));
        }
        else {
            property = ((Jsep.IdentifierNode)node.property).name;
        }
        return this.evalMember(target, property, context);
    }

    public Object eval(Jsep.LiteralNode node, Map<String, Object> context) {
        return node.value;
    }

    public Object eval(Jsep.DatetimeNode node, Map<String, Object> context) {
        return node.value;
    }

    public Object eval(Jsep.DateNode node, Map<String, Object> context) {
        return node.value;
    }

    public Object eval(Jsep.TimeNode node, Map<String, Object> context) {
        return node.value;
    }

    public Object eval(Jsep.ThisExpressionNode node, Map<String, Object> context) {
        return this.evalThis(context);
    }

    public Object eval(Jsep.CallExpressionNode node, Map<String, Object> context) {
        Object callee = this.eval(node.callee, context);
        List<Object> arguments = new List<Object>();
        for(Jsep.Node argNode : node.arguments) {
            arguments.add(this.eval(argNode, context));
        }

        return this.evalCall(callee, arguments, context);
    }

    public Object eval(Jsep.UnaryExpressionNode node, Map<String, Object> context) {
        Object val = this.eval(node.argument, context);
        String op = node.operator;
        if(op == '-') {
            if(val instanceof Decimal) {
                return -((Decimal)val);
            }
            throw new EvalException('Failed to execute "-" on non-number');

        }
        if(op == '!') {
            if(val instanceof Boolean) {
                return !((Boolean)val);
            }
            throw new EvalException('Failed to execute "!" on non-boolean');
        }
        if(op == '+') {
            if(val instanceof Decimal) {
                return +((Decimal)val);
            }
            throw new EvalException('Failed to execute "+" on non-number');

        }
        if(op == '++') {
            if(val instanceof Decimal) {
                return ((Decimal)val) + 1;
            }
            throw new EvalException('Failed to execute "++" on non-number');

        }
        if(op == '--') {
            if(val instanceof Decimal) {
                return ((Decimal)val) - 1;
            }
            throw new EvalException('Failed to execute "--" on non-number');

        }
        throw new EvalException('Unsupported operator for "' + op + '"');

    }

    public Object eval(Jsep.BinaryExpressionNode node, Map<String, Object> context) {

        Object left = this.eval(node.left, context);
        Object right = this.eval(node.right, context);
        String operator = node.operator;
        if(operator == '==') {
            return left == right;
        }
        if(operator == '!=') {
            return left != right;
        }
        if(operator == '===') {
            return left == right;
        }
        if(operator == '!==') {
            return left != right;
        }
        Boolean leftIsNull = (left == null);
        Boolean rightIsNull = (right == null);

        if(operator == '<') {

            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) < ((Decimal)right);
            }
            if((leftIsNull || left instanceof String) && (rightIsNull || right instanceof String)) {
                return ((String)left) < ((String)right);
            }
            if((leftIsNull || left instanceof Date) && (rightIsNull || right instanceof Date)) {
                return ((Date)left) < ((Date)right);
            }
            if((leftIsNull || left instanceof Time) && (rightIsNull || right instanceof Time)) {
                return ((Time)left) < ((Time)right);
            }
            if((leftIsNull || left instanceof Datetime) && (rightIsNull || right instanceof Datetime)) {
                return ((Datetime)left) < ((Datetime)right);
            }
            throw new EvalException('Failed to execute "<" on objects');

        }
        if(operator == '>') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) > ((Decimal)right);
            }
            if((leftIsNull || left instanceof String) && (rightIsNull || right instanceof String)) {
                return ((String)left) > ((String)right);
            }
            if((leftIsNull || left instanceof Date) && (rightIsNull || right instanceof Date)) {
                return ((Date)left) > ((Date)right);
            }
            if((leftIsNull || left instanceof Time) && (rightIsNull || right instanceof Time)) {
                return ((Time)left) > ((Time)right);
            }
            if((leftIsNull || left instanceof Datetime) && (rightIsNull || right instanceof Datetime)) {
                return ((Datetime)left) > ((Datetime)right);
            }
            throw new EvalException('Failed to execute ">" on objects');

        }
        if(operator == '<=') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) <= ((Decimal)right);
            }
            if((leftIsNull || left instanceof String) && (rightIsNull || right instanceof String)) {
                return ((String)left) <= ((String)right);
            }
            if((leftIsNull || left instanceof Date) && (rightIsNull || right instanceof Date)) {
                return ((Date)left) <= ((Date)right);
            }
            if((leftIsNull || left instanceof Time) && (rightIsNull || right instanceof Time)) {
                return ((Time)left) <= ((Time)right);
            }
            if((leftIsNull || left instanceof Datetime) && (rightIsNull || right instanceof Datetime)) {
                return ((Datetime)left) <= ((Datetime)right);
            }
            throw new EvalException('Failed to execute "<=" on objects');

        }
        if(operator == '>=') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) >= ((Decimal)right);
            }
            if((leftIsNull || left instanceof String) && (rightIsNull || right instanceof String)) {
                return ((String)left) >= ((String)right);
            }
            if((leftIsNull || left instanceof Date) && (rightIsNull || right instanceof Date)) {
                return ((Date)left) >= ((Date)right);
            }
            if((leftIsNull || left instanceof Time) && (rightIsNull || right instanceof Time)) {
                return ((Time)left) >= ((Time)right);
            }
            if((leftIsNull || left instanceof Datetime) && (rightIsNull || right instanceof Datetime)) {
                return ((Datetime)left) >= ((Datetime)right);
            }
            throw new EvalException('Failed to execute ">=" on objects');
        }
        if(operator == '+') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) + ((Decimal)right);
            }
            if((leftIsNull || left instanceof String) && (rightIsNull || right instanceof String)) {
                return ((String)left) + ((String)right);
            }
            return String.valueOf(left) + String.valueOf(right);

        }
        if(operator == '-') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) - ((Decimal)right);
            }
            throw new EvalException('Failed to execute "-" on objects');

        }
        if(operator == '*') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) * ((Decimal)right);
            }
            throw new EvalException('Failed to execute "*" on objects');
        }
        if(operator == '/') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return ((Decimal)left) / ((Decimal)right);
            }
            throw new EvalException('Failed to execute "/" on objects');
        }
        if(operator == '%') {
            if((leftIsNull || left instanceof Decimal) && (rightIsNull || right instanceof Decimal)) {
                return Math.mod(((Decimal)left).longValue(), ((Decimal)right).longValue());
            }
            throw new EvalException('Failed to execute "%" on objects');
        }
        throw new EvalException('Unsupported operator for "' + operator + '"');

    }

    public Object eval(Jsep.LogicalExpressionNode node, Map<String, Object> context) {
        Object left = this.eval(node.left, context);
        Object right = this.eval(node.right, context);
        String operator = node.operator;

        Boolean leftIsNull = (left == null);
        Boolean rightIsNull = (right == null);

        if(operator == '&&') {
            if((leftIsNull || left instanceof Boolean) && (rightIsNull || right instanceof Boolean)) {
                return ((Boolean)left) && ((Boolean)right);
            }
            throw new EvalException('Failed to execute "&&" on non-boolean');
        }
        if(operator == '||') {
            if((leftIsNull || left instanceof Boolean) && (rightIsNull || right instanceof Boolean)) {
                return ((Boolean)left) || ((Boolean)right);
            }
            throw new EvalException('Failed to execute "||" on non-boolean');
        }
        throw new EvalException('Unsupported operator for "' + operator + '"');
    }

    public Object eval(Jsep.AssignmentExpressionNode node, Map<String, Object> context) {
        // TODO
        return null;
    }

    public Object eval(Jsep.ConditionalExpressionNode node, Map<String, Object> context) {
        Object test = this.eval(node.test, context);
        if(test != null && test instanceof Boolean) {
            if((Boolean)test) {
                return this.eval(node.consequent, context);
            }
            return this.eval(node.alternate, context);

        }
        throw new EvalException('Failed to execute conditional expression as test is not boolean');

    }

    public Object eval(Jsep.ArrayExpressionNode node, Map<String, Object> context) {
        List<Object> mList = new List<Object>();
        for(Jsep.Node elementNode : node.elements) {
            mList.add(this.eval(elementNode, context));
        }
        return mList;
    }

    public Object eval(Jsep.ObjectExpressionNode node, Map<String, Object> context) {
        Map<String, Object> mMap = new Map<String, Object>();
        for(Jsep.Node key : node.data.keySet()) {
            Jsep.Node value = node.data.get(key);
            String keyStr = null;
            if(key instanceof Jsep.LiteralNode) {
                keyStr = String.valueOf(((Jsep.LiteralNode)key).value);
            }
            else {
                keyStr = ((Jsep.IdentifierNode)key).name;
            }
            mMap.put(keyStr, this.eval(value, context));
        }
        return mMap;
    }

    private static Boolean isInteger(String val) {
        try {
            Integer.valueOf(val);
            return true;
        }
        catch(Exception e) {
            return false;
        }
    }

    public class EvalException extends Exception {
    }

    private class ApexScriptEngine extends ScriptEngine {

    }
}