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
public class Jsep {
    // `index` stores the character number we are currently at while `length` is a constant
    // All of the gobbles below will modify `index` as we move along
    private Integer index = 0;
    private String expr;
    private Integer length;

    public Jsep(String expr) {
        this.expr = expr;
        this.length = expr.length();
    }

    public Node parse() {
        List<Node> nodes = new List<Node>();
        Integer ch_i = null;
        Node node = null;

        while(index < length) {
            ch_i = exprICode(index);

            // Expressions can be separated by semicolons, commas, or just inferred without any
            // separators
            if(ch_i == SEMCOL_CODE || ch_i == COMMA_CODE) {
                index++; // ignore separators
            } else {
                // Try to gobble each expression individually
                node = gobbleExpression();
                if(node != null) {
                    push(nodes, node);
                // If we weren't able to find a binary expression and are out of room, then
                // the expression passed in probably has too much
                } else if(index < length) {
                    throwError('Unexpected "' + exprI(index) + '"', index);
                }
            }
        }

        // If there's only one expression just try returning the expression
        if(nodes.size() == 1) {
            return nodes.get(0);
        } else {
            return new CompoundNode(nodes);
        }
    }

    // Responsible for parsing Array literals `[1, 2, 3]`
    // This function assumes that it needs to gobble the opening bracket
    // and then tries to gobble the expressions as arguments.
    private Node gobbleArray() {
        index++;
        return new ArrayExpressionNode(gobbleArguments(CBRACK_CODE));
    }

    private Node gobbleObject() {
        Integer ch_i = null;

        index++;

        Map<Node, Node> data = new Map<Node, Node>();
        Node key = null;
        Node value = null;
        while(true) {
            gobbleSpaces();
            ch_i = exprICode(index);
            if(ch_i == CCBRACK_CODE) {
                if(key != null && value != null) {
                    data.put(key, value);
                }

                index++;
                break;
            }
            else if(isIdentifierPart(ch_i)) {
                key = gobbleIdentifier();
            }
            else if(ch_i == SQUOTE_CODE || ch_i == DQUOTE_CODE) {
                key = gobbleStringLiteral();
            }
            else if(ch_i == COLON_CODE) {
                index++;
                value = gobbleExpression();
            }
            else if(ch_i == COMMA_CODE) {
                if(key != null && value != null) {
                    data.put(key, value);
                }

                key = null;
                value = null;
                index++;
            }
        }

        return new ObjectExpressionNode(data);
    }

    // Responsible for parsing a group of things within parentheses `()`
    // This function assumes that it needs to gobble the opening parenthesis
    // and then tries to gobble everything within that parenthesis, assuming
    // that the next thing it should see is the close parenthesis. If not,
    // then the expression probably doesn't have a `)`
    private Node gobbleGroup() {
        index++;
        Node node = gobbleExpression();
        gobbleSpaces();
        if(exprICode(index) == CPAREN_CODE) {
            index++;
            return node;
        } else {
            throwError('Unclosed (', index);
            return null;
        }
    }

    // Gobble a non-literal variable name. This variable name may include properties
    // e.g. `foo`, `bar.baz`, `foo['bar'].baz`
    // It also gobbles function calls:
    // e.g. `Math.acos(obj.angle)`
    private Node gobbleVariable() {
        Integer ch_i = null;
        Node node = null;
        ch_i = exprICode(index);

        if(ch_i == OPAREN_CODE) {
            node = gobbleGroup();
        } else {
            node = gobbleIdentifier();
        }
        gobbleSpaces();
        ch_i = exprICode(index);
        while(ch_i == PERIOD_CODE || ch_i == OBRACK_CODE || ch_i == OPAREN_CODE) {
            index++;
            if(ch_i == PERIOD_CODE) {
                gobbleSpaces();
                node = new MemberExpressionNode(false, node, gobbleIdentifier());
            } else if(ch_i == OBRACK_CODE) {
                node = new MemberExpressionNode(true, node, gobbleExpression());
                gobbleSpaces();
                ch_i = exprICode(index);
                if(ch_i != CBRACK_CODE) {
                    throwError('Unclosed [', index);
                }
                index++;
            } else if(ch_i == OPAREN_CODE) {
                // A function call is being made; gobble all the arguments
                node = new CallExpressionNode(gobbleArguments(CPAREN_CODE), node);
            }
            gobbleSpaces();
            ch_i = exprICode(index);
        }

        return node;
    }

    // Gobbles a list of arguments within the context of a function call
    // or array literal. This function also assumes that the opening character
    // `(` or `[` has already been gobbled, and gobbles expressions and commas
    // until the terminator character `)` or `]` is encountered.
    // e.g. `foo(bar, baz)`, `my_func()`, or `[bar, baz]`
    private List<Node> gobbleArguments(Integer termination) {
        Integer ch_i = null;
        List<Node> args = new List<Node>();
        Node node = null;
        Boolean closed = false;
        while(index < length) {
            gobbleSpaces();
            ch_i = exprICode(index);
            if(ch_i == termination) { // done parsing
                closed = true;
                index++;
                break;
            } else if (ch_i == COMMA_CODE) { // between expressions
                index++;
            } else {
                node = gobbleExpression();
                if(node == null || node.getType() == COMPOUND) {
                    throwError('Expected comma', index);
                }
                push(args, node);
            }
        }
        if (!closed) {
            throwError('Expected ' + fromCharCode(termination), index);
        }

        return args;
    }

    // Gobbles only identifiers
    // e.g.: `foo`, `_value`, `$x1`
    // Also, this function checks if that identifier is a literal:
    // (e.g. `true`, `false`, `null`) or `this`
    private Node gobbleIdentifier() {
        Integer ch = exprICode(index);
        Integer start = index;
        String identifier = null;

        if(isIdentifierStart(ch)) {
            index++;
        } else {
            throwError('Unexpected ' + exprI(index), index);
        }

        while(index < length) {
            ch = exprICode(index);
            if(isIdentifierPart(ch)) {
                index++;
            } else {
                break;
            }
        }
        identifier = expr.substring(start, index);

        if(literals.containsKey(identifier)) {
            return new LiteralNode(literals.get(identifier), identifier);
        } else if(identifier == this_str) {
            return new ThisExpressionNode();
        } else {
            return new IdentifierNode(identifier);
        }
    }

    // Parses a string literal, staring with single or double quotes with basic support for escape codes
    // e.g. `"hello world"`, `'this is\nJSEP'`
    private Node gobbleStringLiteral() {
        String str = '';
        String quote = exprI(index++);
        Boolean closed = false;
        String ch = null;

        while(index < length) {
            ch = exprI(index++);
            if(ch == quote) {
                closed = true;
                break;
            } else if(ch == '\\') {
                // Check for all of the common escape codes
                ch = exprI(index++);
                if(ch == 'n') {
                    str += '\n';
                }
                else if(ch == 'r') {
                    str += '\r';
                }
                else if(ch == 't') {
                    str += '\t';
                }
                else if(ch == 'b') {
                    str += '\b';
                }
                else if(ch == 'f') {
                    str += '\f';
                }
                else {
                    str += ch;
                }
            } else {
                str += ch;
            }
        }

        if(!closed) {
            throwError('Unclosed quote after "'+str+'"', index);
        }

        return new LiteralNode(str, quote + str + quote);
    }

    // Parse simple numeric literals: `12`, `3.4`, `.5`. Do this by using a string to
    // keep track of everything in the numeric literal and then calling `parseFloat` on that string
    private Node gobbleNumericLiteral() {
        String num = '';
        String ch = null;
        Integer chCode = null;
        while(isDecimalDigit(exprICode(index))) {
            num += exprI(index++);
        }

        if(exprICode(index) == PERIOD_CODE) { // can start with a decimal marker
            num += exprI(index++);

            while(isDecimalDigit(exprICode(index))) {
                num += exprI(index++);
            }
        }

        ch = exprI(index);
        if(ch == 'e' || ch == 'E') { // exponent marker
            num += exprI(index++);
            ch = exprI(index);
            if(ch == '+' || ch == '-') { // exponent sign
                num += exprI(index++);
            }
            while(isDecimalDigit(exprICode(index))) { //exponent itself
                num += exprI(index++);
            }
            if(!isDecimalDigit(exprICode(index-1)) ) {
                throwError('Expected exponent (' + num + exprI(index) + ')', index);
            }
        }

        chCode = exprICode(index);
        // Check to make sure this isn't a variable name that start with a num (123abc)
        if(isIdentifierStart(chCode)) {
            throwError('Variable names cannot start with a num (' +
                        num + exprI(index) + ')', index);
        } else if(chCode == PERIOD_CODE) {
            throwError('Unexpected period', index);
        }

        return new LiteralNode(Decimal.valueOf(num), num);
    }

    static Pattern datetimePattern = Pattern.compile('(^\\d{4}-[01]?\\d-[0-3]?\\dT[0-2]?\\d:[0-5]?\\d:[0-5]?\\d(?:\\.\\d+)?Z?)|(^\\d{4}-[01]?\\d-[0-3]?\\d)|([0-2]?\\d:[0-5]?\\d:[0-5]?\\d(?:\\.\\d+)?Z?)');

    // An individual part of a binary expression:
    // e.g. `foo.bar(baz)`, `1`, `"abc"`, `(a % 2)` (because it's in parenthesis)
    private Node gobbleToken() {
        Integer ch = null;
        String to_check = null;
        Integer tc_len = null;

        gobbleSpaces();
        ch = exprICode(index);
        Boolean isDigit = isDecimalDigit(ch);
        if(isDigit)
        {
            //Datetime (24 characters long): 2018-06-05T10:00:00.000Z
            //Date: 2018-07-22, 2019-7-22, 2019-7-02, 2019-7-2
            //Time: 16:02:03.004Z
            Integer endIndex = index + 24;
            String subStr = this.expr.substring(index, endIndex>this.length? this.length : endIndex);
            Matcher m = datetimePattern.matcher(subStr);
            if(m.find())
            {
                String vStr = m.group(0);
                this.index += vStr.length();

                if(vStr.indexOf('T')>0)
                {
                    return new DatetimeNode((Datetime)JSON.deserialize('"' + vStr + '"', Datetime.class), vStr);
                }

                if(vStr.indexOf('-')>0)
                {
                    return new DateNode(Date.valueOf(vStr), vStr);
                }

                return new TimeNode((Time)JSON.deserialize('"' + vStr + '"', Time.class), vStr);
            }
        }

        if( isDigit || ch == PERIOD_CODE) {
            // Char code 46 is a dot `.` which can start off a numeric literal
            return gobbleNumericLiteral();
        } else if(ch == SQUOTE_CODE || ch == DQUOTE_CODE) {
            // Single or double quotes
            return gobbleStringLiteral();
        } else if (ch == OBRACK_CODE) {
            return gobbleArray();
        } else if(ch == OCBRACK_CODE) {
            return gobbleObject();
        } else {
            Integer endIndex = max_unop_len + index;
            endIndex = endIndex >= length ? length : endIndex;
            to_check = expr.substring(index, endIndex);
            tc_len = to_check.length();
            while(tc_len > 0) {
                if(unary_ops.containsKey(to_check)) {
                    index += tc_len;
                    return new UnaryExpressionNode(to_check, gobbleToken(), true);
                }
                to_check = to_check.substring(0, --tc_len);
            }

            if (isIdentifierStart(ch) || ch == OPAREN_CODE) { // open parenthesis
                // `foo`, `bar.baz`
                return gobbleVariable();
            }
        }

        return null;
    }

    // This function is responsible for gobbling an individual expression,
    // e.g. `1`, `1+2`, `a+(b*2)-Math.sqrt(2)`
    private Node gobbleBinaryExpression() {
        Node node = null;
        String biop = null;
        Integer prec = null;
        List<Object> stack = null;
        BiopInfo biop_info = null;
        Node left = null;
        Node right = null;
        Integer i = null;

        // First, try to get the leftmost thing
        // Then, check to see if there's a binary operator operating on that leftmost thing
        left = gobbleToken();
        biop = gobbleBinaryOp();

        // If there wasn't a binary operator, just return the leftmost node
        if(biop == null) {
            return left;
        }

        // Otherwise, we need to start a stack to properly place the binary operations in their
        // precedence structure
        biop_info = new BiopInfo(biop, binaryPrecedence(biop));

        right = gobbleToken();
        if(right == null) {
            throwError('Expected expression after ' + biop, index);
        }
        stack = new List<Object>{ left, biop_info, right };

        // Properly deal with precedence using [recursive descent](http://www.engr.mun.ca/~theo/Misc/exp_parsing.htm)
        while(true) {
            biop = gobbleBinaryOp();
            if(biop == null) {
                break;
            }

            prec = binaryPrecedence(biop);

            if(prec == 0) {
                break;
            }
            biop_info = new BiopInfo(biop, prec);

            // Reduce: make a binary expression from the three topmost entries.
            while ((stack.size() > 2) && (prec <= ((BiopInfo)stack.get(stack.size() - 2)).prec)) {
                right = (Node)pop(stack);
                biop = ((BiopInfo)pop(stack)).value;
                left = (Node)pop(stack);
                node = createBinaryExpression(biop, left, right);
                push(stack, node);
            }

            node = gobbleToken();
            if(node == null) {
                throwError('Expected expression after ' + biop, index);
            }
            push(stack, biop_info);
            push(stack, node);
        }

        i = stack.size() - 1;
        node = (Node)stack.get(i);
        while(i > 1) {
            node = createBinaryExpression(((BiopInfo)stack.get(i - 1)).value, (Node)stack.get(i - 2), node);
            i -= 2;
        }

        return node;
    }

    // Search for the operation portion of the string (e.g. `+`, `===`)
    // Start by taking the longest possible binary operations (3 characters: `===`, `!==`, `>>>`)
    // and move down from 3 to 2 to 1 character until a matching binary operation is found
    // then, return that binary operation
    private String gobbleBinaryOp() {
        gobbleSpaces();

        Integer endIndex = max_binop_len + index;
        endIndex = endIndex >= length ? length : endIndex;
        String to_check = expr.substring(index, endIndex);
        Integer tc_len = to_check.length();
        while(tc_len > 0) {
            if(binary_ops.containsKey(to_check)) {
                index += tc_len;
                return to_check;
            }
            to_check = to_check.substring(0, --tc_len);
        }

        return null;
    }

    // The main parsing function. Much of this code is dedicated to ternary expressions
    private Node gobbleExpression() {
        Node test = gobbleBinaryExpression();
        Node consequent = null;
        Node alternate = null;
        gobbleSpaces();
        if(exprICode(index) == QUMARK_CODE) {
            // Ternary expression: test ? consequent : alternate
            index++;
            consequent = gobbleExpression();
            if(consequent == null) {
                throwError('Expected expression', index);
            }
            gobbleSpaces();
            if(exprICode(index) == COLON_CODE) {
                index++;
                alternate = gobbleExpression();
                if(alternate == null) {
                    throwError('Expected expression', index);
                }
                return new ConditionalExpressionNode(test, consequent, alternate);
            } else {
                throwError('Expected :', index);
                return null;
            }
        } else {
            return test;
        }
    }

    private Integer exprICode(Integer i) {
        return i >= 0 && i < length ? this.expr.charAt(i) : 0;
    }

    private String exprI(Integer i) {
        return fromCharCode(this.exprICode(i));
    }

    // Push `index` up to the next non-space character
    private void gobbleSpaces() {
        Integer ch = exprICode(index);
        // space or tab
        while(ch == 32 || ch == 9 || ch == 10 || ch == 13) {
            ch = exprICode(++index);
        }
    }



    // This is the full set of types that any JSEP node can be.
    public static final String COMPOUND = 'Compound';
    public static final String IDENTIFIER = 'Identifier';
    public static final String MEMBER_EXP = 'MemberExpression';
    public static final String LITERAL = 'Literal';

    public static final String JSEP_DATE = 'Date';
    public static final String JSEP_DATETIME = 'Datetime';
    public static final String JSEP_TIME = 'Time';

    public static final String THIS_EXP = 'ThisExpression';
    public static final String CALL_EXP = 'CallExpression';
    public static final String UNARY_EXP = 'UnaryExpression';
    public static final String BINARY_EXP = 'BinaryExpression';
    public static final String LOGICAL_EXP = 'LogicalExpression';
    public static final String CONDITIONAL_EXP = 'ConditionalExpression';
    public static final String ARRAY_EXP = 'ArrayExpression';
    public static final String ASSIGNMENT_EXP = 'AssignmentExpression';
    public static final String OBJECT_EXP = 'ObjectExpression';

    private static final Integer PERIOD_CODE = 46; // '.'
    private static final Integer COMMA_CODE  = 44; // ','
    private static final Integer SQUOTE_CODE = 39; // single quote
    private static final Integer DQUOTE_CODE = 34; // double quotes
    private static final Integer OPAREN_CODE = 40; // (
    private static final Integer CPAREN_CODE = 41; // )
    private static final Integer OBRACK_CODE = 91; // [
    private static final Integer CBRACK_CODE = 93; // ]
    private static final Integer OCBRACK_CODE = 123; // {
    private static final Integer CCBRACK_CODE = 125; // }
    private static final Integer QUMARK_CODE = 63; // ?
    private static final Integer SEMCOL_CODE = 59; // ;
    private static final Integer COLON_CODE  = 58; // :

    private static final Boolean t = true;

    // Use a quickly-accessible map to store all of the unary operators
    // Values are set to `true` (it really doesn't matter)
    private static final Map<String, Boolean> unary_ops = new Map<String, Boolean>{
        '-' => t,
        '!' => t,
        '~' => t,
        '+' => t,
        '++' => t,
        '--' => t
    };

    // Also use a map for the binary operations but set their values to their
    // binary precedence for quick reference:
    // see [Order of operations](http://en.wikipedia.org/wiki/Order_of_operations#Programming_language)
    private static final Map<String, Integer> binary_ops = new Map<String, Integer>{
        '=' => 1, '+=' => 1, '-=' => 1, '*=' => 1, '/=' => 1, '%=' => 1, '&=' => 1,
        '|=' => 1, '^=' => 1, '<<=' => 1, '>>=' => 1,
        '||' => 2, '&&' =>  3, '|' =>  4,  '^' => 5,  '&' => 6,
        '==' => 7, '!=' => 7, '===' => 7, '!==' => 7,
        '<' => 8,  '>' => 8,  '<=' => 8,  '>=' => 8,
        '<<' =>9,  '>>' => 9, '>>>' => 9,
        '+' => 10, '-' => 10,
        '*' => 11, '/' => 11, '%' => 11
    };

    private static Integer max_unop_len = getMaxKeyLen(unary_ops);
    private static Integer max_binop_len = getMaxKeyLen(binary_ops);

    // Literals
    // Store the values to return for the various literals we may encounter
    private static final Map<String, Object> literals = new Map<String, Object>{
        'true' => true,
        'false' => false,
        'null' => null
    };

    // Except for `this`, which is special. This could be changed to something like `'self'` as well
    private static final String this_str = 'this';

    private static void push(List<Object> stack, Object item) {
        stack.add(item);
    }

    private static Object pop(List<Object> stack) {
        if(!stack.isEmpty()) {
            return stack.remove(stack.size() - 1);
        }

        return null;
    }

    private static Boolean isLogicalOperator(String operator) {
        return operator == '||' || operator == '&&';
    }

    private static Boolean isAssignmentOperator(String operator) {
        return operator == '=' ||
            operator == '+=' ||
            operator == '-=' ||
            operator == '*=' ||
            operator == '/=' ||
            operator == '%=' ||
            operator == '&=' ||
            operator == '|=' ||
            operator == '^=' ||
            operator == '<<=' ||
            operator == '>>=';
    }

    // Utility function (gets called from multiple places)
    // Also note that `a && b` and `a || b` are *logical* expressions, not binary expressions
    private static Node createBinaryExpression(String operator, Node left, Node right) {
        if(isLogicalOperator(operator)) {
            return new LogicalExpressionNode(operator, left, right);
        }
        else if(isAssignmentOperator(operator)) {
            return new AssignmentExpressionNode(operator, left, right);
        }
        else {
            return new BinaryExpressionNode(operator, left, right);
        }
    }

    // `ch` is a character code in the next three functions
    private static Boolean isDecimalDigit(Integer ch) {
        return (ch >= 48 && ch <= 57); // 0...9
    }

    private static String fromCharCode(Integer ch) {
        return String.fromCharArray(new List<Integer>{ ch });
    }

    private static Boolean isIdentifierStart(Integer ch) {
        return (ch == 36) || (ch == 95) || // `$` and `_`
            (ch >= 65 && ch <= 90) || // A...Z
            (ch >= 97 && ch <= 122) || // a...z
            (ch >= 128 && !binary_ops.containsKey(fromCharCode(ch))); // any non-ASCII that is not an operator
    }

    private static Boolean isIdentifierPart(Integer ch) {
        return (ch >= 48 && ch <= 57) || // 0...9
            isIdentifierStart(ch);
    }

    // Returns the precedence of a binary operator or `0` if it isn't a binary operator
    private static Integer binaryPrecedence(String op_val) {
        if(binary_ops.containsKey(op_val)) {
            return binary_ops.get(op_val);
        }

        return 0;
    }

    // Get return the longest key length of any object
    private static Integer getMaxKeyLen(Map<String, Object> obj) {
        Integer max_len = 0;
        for(String key : obj.keySet()) {
            if(key.length() > max_len) {
                max_len = key.length();
            }
        }
        return max_len;
    }

    private static void throwError(String message, Integer index) {
        throw new ParsingException(message + ' at character ' + index);
    }

    /**
     * Add unary op
     *
     * @param op_name The op name
     */
    public static void addUnaryOp(String op_name) {
        max_unop_len = Math.max(op_name.length(), max_unop_len);
        unary_ops.put(op_name, t);
    }

    /**
     * Add binary op
     *
     * @param op_name
     * @param precedence
     */
    public static void addBinaryOp(String op_name, Integer precedence) {
        max_binop_len = Math.max(op_name.length(), max_binop_len);
        binary_ops.put(op_name, precedence);
    }

    /**
     * Add literal
     *
     * @param literal_name
     * @param literal_value
     */
    public static void addLiteral(String literal_name, Object literal_value) {
        literals.put(literal_name, literal_value);
    }

    /**
     * Remove unary op
     *
     * @param op_name
     */
    public static void removeUnaryOp(String op_name) {
        unary_ops.remove(op_name);
        if(op_name.length() == max_unop_len) {
            max_unop_len = getMaxKeyLen(unary_ops);
        }
    }

    /**
     * Remove all unary ops
     */
    public static void removeAllUnaryOps() {
        unary_ops.clear();
        max_unop_len = 0;
    }

    /**
     * Remove binary op
     *
     * @param op_name
     */
    public static void removeBinaryOp(String op_name) {
        binary_ops.remove(op_name);
        if(op_name.length() == max_binop_len) {
            max_binop_len = getMaxKeyLen(binary_ops);
        }
    }

    /**
     * Remove all binary ops
     */
    public static void removeAllBinaryOps() {
        binary_ops.clear();
        max_binop_len = 0;
    }

    /**
     * Remove literal
     *
     * @param literal_name
     */
    public static void removeLiteral(String literal_name) {
        literals.remove(literal_name);
    }

    /**
     * Remove all literals
     */
    public static void removeAllLiterals() {
        literals.clear();
    }


    private class BiopInfo {
        public String value;
        public Integer prec;

        public BiopInfo(String value, Integer prec) {
            this.value = value;
            this.prec = prec;
        }
    }

    public class ParsingException extends Exception {
    }

    public interface Node {
        /**
         * Get the type of the node
         *
         * @return node type
         * */
        String getType();
    }

    public class CompoundNode implements Node {
        public List<Node> body;

        public CompoundNode(List<Node> body) {
            this.body = body;
        }

        public String getType() {
            return COMPOUND;
        }
    }

    public class IdentifierNode implements Node {
        public String name;

        public IdentifierNode(String name) {
            this.name = name;
        }

        public String getType() {
            return IDENTIFIER;
        }
    }

    public class DateNode implements Node {
        public Object value;
        public String raw;

        public DateNode(Object value, String raw) {
            this.value = value;
            this.raw = raw;
        }

        public String getType() {
            return JSEP_DATE;
        }
    }

    public class DatetimeNode implements Node {
        public Object value;
        public String raw;

        public DatetimeNode(Object value, String raw) {
            this.value = value;
            this.raw = raw;
        }

        public String getType() {
            return JSEP_DATETIME;
        }
    }


    public class TimeNode implements Node {
        public Object value;
        public String raw;

        public TimeNode(Object value, String raw) {
            this.value = value;
            this.raw = raw;
        }

        public String getType() {
            return JSEP_TIME;
        }
    }


    public class MemberExpressionNode implements Node {
        public Boolean computed;
        public Node target;
        public Node property;

        public MemberExpressionNode(Boolean computed, Node target, Node property) {
            this.computed = computed;
            this.target = target;
            this.property = property;
        }

        public String getType() {
            return MEMBER_EXP;
        }
    }

    public class LiteralNode implements Node {
        public Object value;
        public String raw;

        public LiteralNode(Object value, String raw) {
            this.value = value;
            this.raw = raw;
        }

        public String getType() {
            return LITERAL;
        }
    }

    public class ThisExpressionNode implements Node {
        public String getType() {
            return THIS_EXP;
        }
    }

    public class CallExpressionNode implements Node {
        public List<Node> arguments;
        public Node callee;

        public CallExpressionNode(List<Node> arguments, Node callee) {
            this.arguments = arguments;
            this.callee = callee;
        }

        public String getType() {
            return CALL_EXP;
        }
    }

    public class UnaryExpressionNode implements Node {
        public String operator;
        public Node argument;
        public Boolean prefix;

        public UnaryExpressionNode(String operator, Node argument, Boolean prefix) {
            this.operator = operator;
            this.argument = argument;
            this.prefix = prefix;
        }

        public String getType() {
            return UNARY_EXP;
        }
    }

    public class BinaryExpressionNode implements Node {
        public String operator;
        public Node left;
        public Node right;

        public BinaryExpressionNode(String operator, Node left, Node right) {
            this.operator = operator;
            this.left = left;
            this.right = right;
        }
        public String getType() {
            return BINARY_EXP;
        }
    }

    public class AssignmentExpressionNode implements Node {
        public String operator;
        public Node left;
        public Node right;

        public AssignmentExpressionNode(String operator, Node left, Node right) {
            this.operator = operator;
            this.left = left;
            this.right = right;
        }
        public String getType() {
            return ASSIGNMENT_EXP;
        }
    }

    public class LogicalExpressionNode implements Node {
        public String operator;
        public Node left;
        public Node right;

        public LogicalExpressionNode(String operator, Node left, Node right) {
            this.operator = operator;
            this.left = left;
            this.right = right;
        }

        public String getType() {
            return LOGICAL_EXP;
        }
    }

    public class ConditionalExpressionNode implements Node {
        public Node test;
        public Node consequent;
        public Node alternate;

        public ConditionalExpressionNode(Node test, Node consequent, Node alternate) {
            this.test = test;
            this.consequent = consequent;
            this.alternate = alternate;
        }

        public String getType() {
            return CONDITIONAL_EXP;
        }
    }

    public class ArrayExpressionNode implements Node {
        public List<Node> elements;

        public ArrayExpressionNode(List<Node> elements) {
            this.elements = elements;
        }

        public String getType() {
            return ARRAY_EXP;
        }
    }

    public class ObjectExpressionNode implements Node {
        public Map<Node, Node> data;

        public ObjectExpressionNode(Map<Node, Node> data) {
            this.data = data;
        }

        public String getType() {
            return OBJECT_EXP;
        }
    }
}