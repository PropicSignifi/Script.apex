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
@IsTest
private class JsepTest {
    @IsTest
    private static void assignmentTest() {
        Jsep.AssignmentExpressionNode node = (Jsep.AssignmentExpressionNode)new Jsep('a = b').parse();
        System.assertEquals('=', node.operator);
        System.assertEquals(node.getType(), Jsep.ASSIGNMENT_EXP);
    }

    @IsTest
    private static void groupTest() {
        Jsep.Node node = new Jsep('(1 + 2) * 3').parse();
        System.assert(node != null);
    }

    @IsTest
    private static void callTest() {
        Jsep.CallExpressionNode node = (Jsep.CallExpressionNode)new Jsep('a(b)').parse();
        System.assertEquals(1, node.arguments.size());
        System.assertEquals(node.getType(), Jsep.CALL_EXP);
    }

    @IsTest
    private static void memberTest() {
        Jsep.MemberExpressionNode node = (Jsep.MemberExpressionNode)new Jsep('a.b').parse();
        System.assertEquals(false, node.computed);
        System.assertEquals(node.getType(), Jsep.MEMBER_EXP);

        node = (Jsep.MemberExpressionNode)new Jsep('a[b]').parse();
        System.assertEquals(true, node.computed);
    }

    @IsTest
    private static void conditionalTest() {
        Jsep.ConditionalExpressionNode node = (Jsep.ConditionalExpressionNode)new Jsep('a ? b : c').parse();
        System.assert(node != null);
        System.assertEquals(node.getType(), Jsep.CONDITIONAL_EXP);
    }

    @IsTest
    private static void binaryTest() {
        Jsep.BinaryExpressionNode node = (Jsep.BinaryExpressionNode)new Jsep('a + b').parse();
        System.assertEquals('+', node.operator);
        System.assertEquals(node.getType(), Jsep.BINARY_EXP);
    }

    @IsTest
    private static void logicalTest() {
        Jsep.LogicalExpressionNode node = (Jsep.LogicalExpressionNode)new Jsep('a && b').parse();
        System.assertEquals('&&', node.operator);
        System.assertEquals(node.getType(), Jsep.LOGICAL_EXP);
    }

    @IsTest
    private static void unaryTest() {
        Jsep.UnaryExpressionNode node = (Jsep.UnaryExpressionNode)new Jsep('-a').parse();
        System.assertEquals('-', node.operator);
        System.assertEquals(node.getType(), Jsep.UNARY_EXP);

        Jsep.IdentifierNode node1 = (Jsep.IdentifierNode)node.argument;
        System.assertEquals('a', node1.name);
    }

    @IsTest
    private static void identifierTest() {
        Jsep.IdentifierNode node = (Jsep.IdentifierNode)new Jsep('name').parse();
        System.assertEquals('name', node.name);
        System.assertEquals(node.getType(), Jsep.IDENTIFIER);
    }

    @IsTest
    private static void compoundTest() {
        Jsep.CompoundNode node = (Jsep.CompoundNode)new Jsep('1, 2').parse();
        System.assertEquals(2, node.body.size());
        System.assertEquals(node.getType(), Jsep.COMPOUND);
    }

    @IsTest
    private static void thisTest() {
        Jsep.ThisExpressionNode node = (Jsep.ThisExpressionNode)new Jsep('this').parse();
        System.assert(node != null);
        System.assertEquals(node.getType(), Jsep.THIS_EXP);
    }

    @IsTest
    private static void literalTest() {
        Jsep.LiteralNode node = (Jsep.LiteralNode)new Jsep('1').parse();
        System.assertEquals(node.value, 1);
        System.assertEquals(node.getType(), Jsep.LITERAL);

        node = (Jsep.LiteralNode)new Jsep('true').parse();
        System.assertEquals(node.value, true);

        node = (Jsep.LiteralNode)new Jsep('"wilson"').parse();
        System.assertEquals(node.value, 'wilson');
    }



     //Datetime (24 characters long): 2018-06-05T10:00:00.000Z
            //Date: 2018-07-22, 2019-7-22, 2019-7-02, 2019-7-2
            //Time: 16:02:03.004Z
    @IsTest
    private static void datetimeNodeTypeTest() {

        Jsep.Node node = new Jsep('"2019-07-24T01:08:54.474Z"').parse();
        System.assertEquals(node.getType(), Jsep.LITERAL);

        node = new Jsep('"2019-07-24"').parse();
        System.assertEquals(node.getType(), Jsep.LITERAL);

        node = new Jsep('"01:08:54.474Z"').parse();
        System.assertEquals(node.getType(), Jsep.LITERAL);

        node = new Jsep('2019-07-24T01:08:54.474Z').parse();
        System.assertEquals(node.getType(), Jsep.JSEP_DATETIME);

        node = new Jsep('2019-07-24').parse();
        System.assertEquals(node.getType(), Jsep.JSEP_DATE);

        node = new Jsep('01:08:54.474Z').parse();
        System.assertEquals(node.getType(), Jsep.JSEP_TIME);
    }

    @IsTest
    private static void datetimeTest() {
        String s = '2019-07-24T01:08:54.474Z';
        String s2= '2019-7-24T01:08:54.474Z';
        String s3= '2019-7-24T1:8:54.474Z';
        Datetime v = (Datetime)JSON.deserialize('"' + s + '"', Datetime.class);
        Jsep.DatetimeNode node = (Jsep.DatetimeNode)new Jsep(s).parse();
        System.assertEquals(node.value, v);
        System.assertEquals(node.getType(), Jsep.JSEP_DATETIME);

        node = (Jsep.DatetimeNode)new Jsep(s2).parse();
        System.assertEquals(node.value, v);

        node = (Jsep.DatetimeNode)new Jsep(s3).parse();
        System.assertEquals(node.value, v);
    }

    @IsTest
    private static void dateTest() {
        String s = '2019-07-04';
        String s2= '2019-7-4';
        String s3= '2019-7-04';
        Date v = (Date)JSON.deserialize('"' + s + '"', Date.class);
        Jsep.DateNode node = (Jsep.DateNode)new Jsep(s).parse();
        System.assertEquals(node.value, v);
        System.assertEquals(node.getType(), Jsep.JSEP_DATE);

        node = (Jsep.DateNode)new Jsep(s2).parse();
        System.assertEquals(node.value, v);
        System.assertEquals(node.getType(), Jsep.JSEP_DATE);

        node = (Jsep.DateNode)new Jsep(s3).parse();
        System.assertEquals(node.value, v);
        System.assertEquals(node.getType(), Jsep.JSEP_DATE);
    }

    @IsTest
    private static void timeTest() {
        String s = '01:08:54.474';
        String s2= '1:08:54.474';
        String s3= '1:8:54.474';
        String s4= '1:8:54.474Z';
        Time v = (Time)JSON.deserialize('"' + s + '"', Time.class);
        Jsep.TimeNode node = (Jsep.TimeNode )new Jsep(s).parse();
        System.assertEquals(node.value, v);
        System.assertEquals(node.getType(), Jsep.JSEP_TIME);

        node = (Jsep.TimeNode )new Jsep(s2).parse();
        System.assertEquals(node.value, v);
        System.assertEquals(node.getType(), Jsep.JSEP_TIME);

        node = (Jsep.TimeNode )new Jsep(s3).parse();
        System.assertEquals(node.value, v);
        System.assertEquals(node.getType(), Jsep.JSEP_TIME);

        node = (Jsep.TimeNode )new Jsep(s4).parse();
        System.assertEquals(true, node.value!=v);
        System.assertEquals(node.getType(), Jsep.JSEP_TIME);
    }




    @IsTest
    private static void arrayTest() {
        Jsep.ArrayExpressionNode node = (Jsep.ArrayExpressionNode)new Jsep('[ 1, 2, 3 ]').parse();
        System.assertEquals(3, node.elements.size());
        System.assertEquals(node.getType(), Jsep.ARRAY_EXP);
        Jsep.LiteralNode node1 = (Jsep.LiteralNode)node.elements.get(0);
        System.assertEquals(1, node1.value);
    }

    @IsTest
    private static void objectTest() {
        Jsep.ObjectExpressionNode node = (Jsep.ObjectExpressionNode)new Jsep('{ name: "test" }').parse();
        System.assertEquals(node.getType(), Jsep.OBJECT_EXP);
    }

    @IsTest
    private static void addBinaryOpTest() {
        Jsep.addBinaryOp('**', 10);
        Jsep.Node node = (Jsep.Node)new Jsep('1 ** 1').parse();
        System.assert(node != null);
    }

    @IsTest
    private static void addUnaryOpTest() {
        Jsep.addUnaryOp('^');
        Jsep.Node node = (Jsep.Node)new Jsep('^a').parse();
        System.assert(node != null);
    }

    @IsTest
    private static void addLiteralTest() {
        Jsep.addLiteral('msg', 'msg');
        Jsep.Node node = (Jsep.Node)new Jsep('msg').parse();
        System.assert(node != null);
    }

    @IsTest
    private static void removeUnaryOpTest() {
        Jsep.removeUnaryOp('!');
        try {
            new Jsep('!a').parse();
            System.assertEquals(true, false);
        }
        catch(Exception e) {
        }
    }

    @IsTest
    private static void removeBinaryOpTest() {
        Jsep.removeBinaryOp('*');
        try {
            new Jsep('1 * 2').parse();
            System.assertEquals(true, false);
        }
        catch(Exception e) {
        }
    }

    @IsTest
    private static void removeLiteralTest() {
        Jsep.removeLiteral('true');
        Jsep.Node node = new Jsep('true').parse();
        System.assertEquals(node.getType(), JSep.IDENTIFIER);
    }
}
