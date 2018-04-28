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
    }

    @IsTest
    private static void memberTest() {
        Jsep.MemberExpressionNode node = (Jsep.MemberExpressionNode)new Jsep('a.b').parse();
        System.assertEquals(false, node.computed);

        node = (Jsep.MemberExpressionNode)new Jsep('a[b]').parse();
        System.assertEquals(true, node.computed);
    }

    @IsTest
    private static void conditionalTest() {
        Jsep.ConditionalExpressionNode node = (Jsep.ConditionalExpressionNode)new Jsep('a ? b : c').parse();
        System.assert(node != null);
    }

    @IsTest
    private static void binaryTest() {
        Jsep.BinaryExpressionNode node = (Jsep.BinaryExpressionNode)new Jsep('a + b').parse();
        System.assertEquals('+', node.operator);
    }

    @IsTest
    private static void logicalTest() {
        Jsep.LogicalExpressionNode node = (Jsep.LogicalExpressionNode)new Jsep('a && b').parse();
        System.assertEquals('&&', node.operator);
    }

    @IsTest
    private static void unaryTest() {
        Jsep.UnaryExpressionNode node = (Jsep.UnaryExpressionNode)new Jsep('-a').parse();
        System.assertEquals('-', node.operator);
        Jsep.IdentifierNode node1 = (Jsep.IdentifierNode)node.argument;
        System.assertEquals('a', node1.name);
    }

    @IsTest
    private static void identifierTest() {
        Jsep.IdentifierNode node = (Jsep.IdentifierNode)new Jsep('name').parse();
        System.assertEquals('name', node.name);
    }

    @IsTest
    private static void compoundTest() {
        Jsep.CompoundNode node = (Jsep.CompoundNode)new Jsep('1, 2').parse();
        System.assertEquals(2, node.body.size());
    }

    @IsTest
    private static void thisTest() {
        Jsep.ThisExpressionNode node = (Jsep.ThisExpressionNode)new Jsep('this').parse();
        System.assert(node != null);
    }

    @IsTest
    private static void literalTest() {
        Jsep.LiteralNode node = (Jsep.LiteralNode)new Jsep('1').parse();
        System.assertEquals(node.value, 1);

        node = (Jsep.LiteralNode)new Jsep('true').parse();
        System.assertEquals(node.value, true);

        node = (Jsep.LiteralNode)new Jsep('"wilson"').parse();
        System.assertEquals(node.value, 'wilson');
    }

    @IsTest
    private static void arrayTest() {
        Jsep.ArrayExpressionNode node = (Jsep.ArrayExpressionNode)new Jsep('[ 1, 2, 3 ]').parse();
        System.assertEquals(3, node.elements.size());
        Jsep.LiteralNode node1 = (Jsep.LiteralNode)node.elements.get(0);
        System.assertEquals(1, node1.value);
    }
}
