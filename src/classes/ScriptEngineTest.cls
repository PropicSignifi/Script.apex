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
private class ScriptEngineTest {
    static ScriptEngine se = ScriptEngine.getInstance();
    @IsTest
    private static void objectTest() {
        Jsep.Node node = new Jsep('{ name: "wilson" }').parse();
        Map<String, Object> context = new Map<String, Object>{};
        System.assertEquals(
            new Map<String, Object>{ 'name' => 'wilson'},
            se.eval(node, context)
        );
    }

    @IsTest
    private static void arrayTest() {
        Jsep.Node node = new Jsep('["a", "b"]').parse();
        Map<String, Object> context = new Map<String, Object>{};
        System.assertEquals(
            new List<Object>{ 'a', 'b' },
            se.eval(node, context)
        );
    }

    @IsTest
    private static void conditionalTest() {
        Jsep.Node node = new Jsep('a ? 1 : 2').parse();
        Map<String, Object> context = new Map<String, Object>{
            'a' => true,
            'b' => false
        };
        System.assertEquals(
            1,
            se.eval(node, context)
        );
    }

    @IsTest
    private static void logicalTest() {
        Jsep.Node node = new Jsep('a && b').parse();
        Map<String, Object> context = new Map<String, Object>{
            'a' => true,
            'b' => false
        };
        System.assertEquals(
            false,
            se.eval(node, context)
        );
    }

    @IsTest
    private static void binaryTest() {
        Jsep.Node node = new Jsep('a + b').parse();
        Map<String, Object> context = new Map<String, Object>{
            'a' => 1,
            'b' => 2
        };
        System.assertEquals(
            3,
            se.eval(node, context)
        );
    }

    @IsTest
    private static void unaryTest() {
        Jsep.Node node = new Jsep('!true').parse();
        Map<String, Object> context = new Map<String, Object>();
        System.assertEquals(
            false,
            se.eval(node, context)
        );
    }

    @IsTest
    private static void thisTest() {
        Jsep.Node node = new Jsep('this').parse();
        Map<String, Object> context = new Map<String, Object>();
        System.assertEquals(
            context,
            se.eval(node, context)
        );
    }

    @IsTest
    private static void literalTest() {
        Jsep.Node node = new Jsep('null').parse();
        System.assertEquals(
            null,
            se.eval(node)
        );
    }

    @IsTest
    private static void memberTest() {
        Jsep.Node node = new Jsep('a.b').parse();
        System.assertEquals(
            3,
            se.eval(node, new Map<String, Object>{ 'a' => new Map<String, Object>{ 'b' => 3 } })
        );

        node = new Jsep('a[0]').parse();
        System.assertEquals(
            3,
            se.eval(node, new Map<String, Object>{ 'a' => new List<Object>{ 3 } })
        );

        node = new Jsep('a[0]').parse();
        System.assertEquals(
            '3',
            se.eval(node, new Map<String, Object>{ 'a' => '345' })
        );

        node = new Jsep('a.Description').parse();
        System.assertEquals(
            'desc',
            se.eval(node, new Map<String, Object>{ 'a' => new Account(Description = 'desc')})
        );
    }

    @IsTest
    private static void identifierTest() {
        Jsep.Node node = new Jsep('a').parse();
        System.assertEquals(
            null,
            se.eval(node)
        );

        System.assertEquals(
            3,
            se.eval(node, new Map<String, Object>{ 'a' => 3 })
        );
    }

    @IsTest
    private static void compoundTest() {
        Jsep.Node node = new Jsep('"a", "b"').parse();
        System.assertEquals(
            new List<Object>{ 'a', 'b' },
            se.eval(node)
        );
    }

    @IsTest
    private static void instanceTest() {
        System.assert(se != null);
    }

    @IsTest
    private static void evalTest() {
        System.assertEquals('abc', se.eval('"a" + "b" + "c"'));
    }

    @IsTest
    private static void evalContextTest() {
        Map<String, Object> context = new Map<String, Object>{
            'a' => true,
            'b' => false
        };
        System.assertEquals(false, se.eval('a && b', context));
        System.assertEquals(true, se.eval('a || b', context));
    }

    @IsTest
    private static void callTest() {
        System.assertEquals(null, se.eval('test(1)'));
    }

    @IsTest
    private static void assignmentTest() {
        System.assertEquals(null, se.eval('a = 1'));
    }

    @IsTest
    private static void moreUnaryTest() {
        System.assertEquals(-1, se.eval('-1'));

        System.assertEquals(1, se.eval('+1'));

        System.assertEquals(false, se.eval('!true'));

        System.assertEquals(2, se.eval('++1'));

        System.assertEquals(0, se.eval('--1'));
    }

    @IsTest
    private static void moreBinaryTest() {
        System.assertEquals(true, se.eval(' 1 == 1'));
        System.assertEquals(true, se.eval(' 1 != 2'));
        System.assertEquals(true, se.eval(' 1 < 2'));
        System.assertEquals(true, se.eval(' 3 > 2'));
        System.assertEquals(true, se.eval(' 1 <= 2'));
        System.assertEquals(true, se.eval(' 3 >= 2'));

        System.assertEquals(1, se.eval('1 + 0'));
        System.assertEquals(1, se.eval('1 - 0'));
        System.assertEquals(1, se.eval('1 * 1'));
        System.assertEquals(1, se.eval('1 / 1'));
        System.assertEquals(1, se.eval('1 % 2'));

        System.assertEquals(true, se.eval('"a" == "a"'));
        System.assertEquals(true, se.eval('"a" != "b"'));
        System.assertEquals(true, se.eval('"a" < "b"'));
        System.assertEquals(true, se.eval('"c" > "b"'));
        System.assertEquals(true, se.eval('"a" <= "b"'));
        System.assertEquals(true, se.eval('"c" >= "b"'));

        System.assertEquals(true, se.eval('a == b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).date(),
            'b' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).date()
        }));
        System.assertEquals(true, se.eval('a != b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).date(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).date()
        }));
        System.assertEquals(true, se.eval('a < b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).date(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).date()
        }));
        System.assertEquals(true, se.eval('a <= b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).date(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).date()
        }));
        System.assertEquals(true, se.eval('a > b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 3, 3, 0, 0).date(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).date()
        }));
        System.assertEquals(true, se.eval('a >= b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 3, 3, 0, 0).date(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).date()
        }));

        System.assertEquals(true, se.eval('a == b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).time(),
            'b' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).time()
        }));
        System.assertEquals(true, se.eval('a != b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).time(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).time()
        }));
        System.assertEquals(true, se.eval('a < b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).time(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).time()
        }));
        System.assertEquals(true, se.eval('a <= b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0).time(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).time()
        }));
        System.assertEquals(true, se.eval('a > b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 3, 3, 0, 0).time(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).time()
        }));
        System.assertEquals(true, se.eval('a >= b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 3, 3, 0, 0).time(),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0).time()
        }));

        System.assertEquals(true, se.eval('a == b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0),
            'b' => Datetime.newInstance(2018, 1, 1, 1, 0, 0)
        }));
        System.assertEquals(true, se.eval('a != b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0)
        }));
        System.assertEquals(true, se.eval('a < b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0)
        }));
        System.assertEquals(true, se.eval('a <= b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 1, 1, 0, 0),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0)
        }));
        System.assertEquals(true, se.eval('a > b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 3, 3, 0, 0),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0)
        }));
        System.assertEquals(true, se.eval('a >= b', new Map<String, Object>{
            'a' => Datetime.newInstance(2018, 1, 3, 3, 0, 0),
            'b' => Datetime.newInstance(2018, 1, 2, 2, 0, 0)
        }));
    }

    @isTest
    private static void datetimeTest() {
        String s = '2019-07-24T01:08:54.474Z==2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '2019-07-24T1:08:54.474Z==2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '2018-07-24T1:08:54.474Z<=2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '2018-07-24T1:08:54.474Z<2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '2020-07-24T1:08:54.474Z<2019-07-24T01:08:54.474Z';
        System.assertEquals(false, se.eval(s));

        s = '2020-07-24T1:08:54.474Z>=2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '2020-07-24T1:08:54.474Z>2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '2020-07-24T1:08:54.474Z!=2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));


        s = '2020-07-24>2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));


         s = '2020-07-24T1:08:54.474Z>2019-07-24';
        System.assertEquals(true, se.eval(s));


        s = '2019-07-24T1:08:54.474Z>2019-07-24';
        System.assertEquals(true, se.eval(s));

   }


    @isTest
    private static void dateTest() {
        String s = '2019-07-24==2019-07-24';
        System.assertEquals(true, se.eval(s));

        s = '2019-7-24==2019-07-24';
        System.assertEquals(true, se.eval(s));

        s = '2018-07-24<=2019-07-24';
        System.assertEquals(true, se.eval(s));

        s = '2018-7-4<2019-07-24';
        System.assertEquals(true, se.eval(s));

        s = '2020-07-24<2019-07-24';
        System.assertEquals(false, se.eval(s));

        s = '2020-07-24>=2019-07-24';
        System.assertEquals(true, se.eval(s));

        s = '2020-07-24>2019-07-24';
        System.assertEquals(true, se.eval(s));

        s = '2020-07-24!=2019-07-24';
        System.assertEquals(true, se.eval(s));


        s = '2020-07-24>2019-07-24T01:08:54.474Z';
        System.assertEquals(true, se.eval(s));


         s = '2020-07-24T1:08:54.474Z>2019-07-24';
        System.assertEquals(true, se.eval(s));


        s = '2019-07-24T1:08:54.474Z>2019-07-24';
        System.assertEquals(true, se.eval(s));

   }


   @isTest
    private static void timeTest() {
        String s = '01:08:54.474Z==01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '1:08:54.474Z==01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '1:08:54.474Z<=01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '1:08:54.474Z<02:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '23:08:54.474Z<01:08:54.474Z';
        System.assertEquals(false, se.eval(s));

        s = '21:08:54.000Z>=01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '21:08:54.474Z>01:08:54.474Z';
        System.assertEquals(true, se.eval(s));

        s = '01:08:54.474Z!=11:08:54.474Z';
        System.assertEquals(true, se.eval(s));
    }

    @isTest
    private static void nullTests() {
        Map<String, Object> context = new Map<String, Object>();
        context.put('Datetime1__c', Datetime.now());
        context.put('Date1__c', Date.today());
        context.put('Time1__c', (Time)JSON.deserialize('"01:08:54.474Z"', Time.class));
        context.put('BooleanTrue__c', true);
        context.put('BooleanFalse__c', true);
        context.put('Decimal1__c', 100.5);
        context.put('String1__c', 'StringValue1');

        //null vs null
        System.assertEquals(true, se.eval('$bogusField__c ==$nullValue', context));
        System.assertEquals(false, se.eval('$bogusField__c>=$nullValue', context));
        System.assertEquals(false, se.eval('$bogusField__c>$nullValue', context));
        System.assertEquals(false, se.eval('$bogusField__c<=$nullValue', context));
        System.assertEquals(false, se.eval('$bogusField__c<$nullValue', context));
        System.assertEquals(false, se.eval('$bogusField__c!=$nullValue', context));


        System.assertEquals(false, se.eval('Datetime1__c==$nullValue', context));
        System.assertEquals(false, se.eval('Datetime1__c>=$nullValue', context));
        System.assertEquals(false, se.eval('Datetime1__c>$nullValue', context));
        System.assertEquals(false, se.eval('Datetime1__c<=$nullValue', context));
        System.assertEquals(false, se.eval('Datetime1__c<$nullValue', context));
        System.assertEquals(true, se.eval('Datetime1__c!=$nullValue', context));

        System.assertEquals(false, se.eval('$nullValue == Datetime1__c', context));
        System.assertEquals(false, se.eval('$nullValue >= Datetime1__c', context));
        System.assertEquals(false, se.eval('$nullValue > Datetime1__c', context));
        System.assertEquals(false, se.eval('$nullValue <= Datetime1__c', context));
        System.assertEquals(false, se.eval('$nullValue < Datetime1__c', context));
        System.assertEquals(true, se.eval('$nullValue != Datetime1__c', context));
        System.assertEquals(true, se.eval('$nullValue==null || Datetime1__c>=$nullValue', context));

        System.assertEquals(false, se.eval('Date1__c==$nullValue', context));
        System.assertEquals(false, se.eval('Date1__c>=$nullValue', context));
        System.assertEquals(false, se.eval('Date1__c>$nullValue', context));
        System.assertEquals(false, se.eval('Date1__c<=$nullValue', context));
        System.assertEquals(false, se.eval('Date1__c<$nullValue', context));
        System.assertEquals(true, se.eval('Date1__c!=$nullValue', context));
        System.assertEquals(false, se.eval('$nullValue == Date1__c', context));
        System.assertEquals(false, se.eval('$nullValue >= Date1__c', context));
        System.assertEquals(false, se.eval('$nullValue > Date1__c', context));
        System.assertEquals(false, se.eval('$nullValue <= Date1__c', context));
        System.assertEquals(false, se.eval('$nullValue < Date1__c', context));
        System.assertEquals(true, se.eval('$nullValue != Date1__c', context));
        System.assertEquals(true, se.eval('$nullValue==null || Date1__c>=$nullValue', context));


        System.assertEquals(false, se.eval('Time1__c==$nullValue', context));
        System.assertEquals(false, se.eval('Time1__c>=$nullValue', context));
        System.assertEquals(false, se.eval('Time1__c>$nullValue', context));
        System.assertEquals(false, se.eval('Time1__c<=$nullValue', context));
        System.assertEquals(false, se.eval('Time1__c<$nullValue', context));
        System.assertEquals(true, se.eval('Time1__c!=$nullValue', context));
        System.assertEquals(false, se.eval('$nullValue == Time1__c', context));
        System.assertEquals(false, se.eval('$nullValue >= Time1__c', context));
        System.assertEquals(false, se.eval('$nullValue > Time1__c', context));
        System.assertEquals(false, se.eval('$nullValue <= Time1__c', context));
        System.assertEquals(false, se.eval('$nullValue < Time1__c', context));
        System.assertEquals(true, se.eval('$nullValue != Time1__c', context));
        System.assertEquals(true, se.eval('$nullValue==null || Time1__c>=$nullValue', context));


        System.assertEquals(false, se.eval('String1__c==$nullValue', context));
        System.assertEquals(true, se.eval('String1__c>=$nullValue', context));
        System.assertEquals(true, se.eval('String1__c>$nullValue', context));
        System.assertEquals(false, se.eval('String1__c<=$nullValue', context));
        System.assertEquals(false, se.eval('String1__c<$nullValue', context));
        System.assertEquals(true, se.eval('String1__c!=$nullValue', context));
        System.assertEquals(false, se.eval('$nullValue == String1__c', context));
        System.assertEquals(false, se.eval('$nullValue >= String1__c', context));
        System.assertEquals(false, se.eval('$nullValue > String1__c', context));
        System.assertEquals(true, se.eval('$nullValue <= String1__c', context));
        System.assertEquals(true, se.eval('$nullValue < String1__c', context));
        System.assertEquals(true, se.eval('$nullValue != String1__c', context));
        System.assertEquals(false, se.eval('$nullValue!=null || $nullValue>String1__c', context));

    }


}
