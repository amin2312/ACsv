# -*- coding: UTF-8 -*-

import acsv2_7 as acsv;
import json;

class Demo:

    @staticmethod
    def main():
        f = open( "release/csvs/standard_format_text.csv", "r")
        Demo._tab1 = acsv.Table.Parse(f.read())
        Demo.test_standard_csv_format()
        f = open( "release/csvs/enhanced_format_text.csv", "r")
        Demo._tab2 = acsv.Table.Parse(f.read())
        Demo.test_enhanced_csv_format()

    @staticmethod
    def P(cmd,o):
        print(cmd)
        if (o is None):
            print(str(None))
        else:
            print(o)
            #print(json.dumps(o, ensure_ascii=False))
        print('\n')

    @staticmethod
    def test_standard_csv_format():
        Demo.P("select ALL to rows",Demo._tab1.selectAll().toRows())
        Demo.P("select ALL to objs",Demo._tab1.selectAll().toObjs())
        Demo.P("select first row",Demo._tab1.selectFirstRow().toFirstRow())
        Demo.P("select first obj",Demo._tab1.selectFirstRow().toFirstObj())
        Demo.P("select last row",Demo._tab1.selectLastRow().toFirstRow())
        Demo.P("select last obj",Demo._tab1.selectLastRow().toFirstObj())
        Demo.P("selectWhenE (id) = \"2\"",Demo._tab1.selectWhenE(1,"2").toFirstObj())
        Demo.P("selectWhenE (id) = \"3\" and (id2) = \"21\"",Demo._tab1.selectWhenE2(1,"3","21").toFirstObj())
        Demo.P("selectWhenE (id) = \"4\" and (id2) = \"21\" and (id3) = \"200\"",Demo._tab1.selectWhenE3(1,"4","21","200").toFirstObj())
        Demo.P("selectWhenE ALL (id2) = \"20\"",Demo._tab1.selectWhenE(0,"20",1).toObjs())
        Demo.P("merge tables",Demo._tab1.merge(Demo._tab1).selectAll().toRows())

    @staticmethod
    def test_enhanced_csv_format():
        Demo.P("[E] select ALL to rows",Demo._tab2.selectAll().toRows())
        Demo.P("[E] select ALL to objs",Demo._tab2.selectAll().toObjs())
        Demo.P("[E] select first row",Demo._tab2.selectFirstRow().toFirstRow())
        Demo.P("[E] select first obj",Demo._tab2.selectFirstRow().toFirstObj())
        Demo.P("[E] select last row",Demo._tab2.selectLastRow().toFirstRow())
        Demo.P("[E] select last obj",Demo._tab2.selectLastRow().toFirstObj())
        Demo.P("[E] selectWhenE (id) = 2",Demo._tab2.selectWhenE(1,2).toFirstObj())
        Demo.P("[E] selectWhenE (id) = -1",Demo._tab2.selectWhenE(1,-1).toFirstObj())
        Demo.P("[E] selectWhenE2 (id) = 3 and (id2) = 22",Demo._tab2.selectWhenE2(1,3,22).toFirstObj())
        Demo.P("[E] selectWhenE2 (id) = 3 and (id2) = -1",Demo._tab2.selectWhenE2(1,3,-1).toFirstObj())
        Demo.P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = 200",Demo._tab2.selectWhenE3(1,4,22,200).toFirstObj())
        Demo.P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = -1",Demo._tab2.selectWhenE3(1,4,22,-1).toFirstObj())
        Demo.P("[E] selectWhenE ALL (id2) = 21",Demo._tab2.selectWhenE(0,21,1).toObjs())
        Demo.P("[E] selectWhenE ALL (id2) = -1",Demo._tab2.selectWhenE(0,-1,1).toObjs())
        Demo.P("[E] selectWhenG ALL (id2) > 25",Demo._tab2.selectWhenG(0,False,25,1).toObjs())
        Demo.P("[E] selectWhenG ALL (id2) >= 25",Demo._tab2.selectWhenG(0,True,25,1).toObjs())
        Demo.P("[E] selectWhenG ALL (id2) > 30",Demo._tab2.selectWhenG(0,False,30,1).toObjs())
        Demo.P("[E] selectWhenL ALL (id2) < 22",Demo._tab2.selectWhenL(0,False,22,1).toObjs())
        Demo.P("[E] selectWhenL ALL (id2) <= 22",Demo._tab2.selectWhenL(0,True,22,1).toObjs())
        Demo.P("[E] selectWhenL ALL (id2) < 20",Demo._tab2.selectWhenL(0,True,20,1).toObjs())
        Demo.P("[E] selectWhenGreaterAndLess ALL (id2) > 21 and (id2) < 24",Demo._tab2.selectWhenGreaterAndLess(0,False,False,21,24,1).toObjs())
        Demo.P("[E] selectWhenGreaterAndLess ALL (id2) >= 21 and (id2) <= 24",Demo._tab2.selectWhenGreaterAndLess(0,True,True,21,24,1).toObjs())
        Demo.P("[E] selectWhenLessOrGreater ALL (id2) < 22 or (id2) > 25",Demo._tab2.selectWhenLessOrGreater(0,False,False,22,25,1).toObjs())
        Demo.P("[E] selectWhenLessOrGreater ALL (id2) <= 22 or (id2) >= 25",Demo._tab2.selectWhenLessOrGreater(0,True,True,22,25,1).toObjs())
        Demo.P("[E] selectWhenIn (id) in 3,4,5",Demo._tab2.selectWhenIn(1,[3, 4, 5]).toObjs())
        Demo.P("[E] selectAt rows at 0,1,10",Demo._tab2.selectAt([0, 1, 10]).toObjs())
        Demo.P("[E] multi selects (id3) = 100 and (id2) < 22",Demo._tab2.selectWhenE(0,100,2).selectWhenL(0,False,22,1).toObjs())
        Demo.P("[E] sort by (id3) = 300 desc (id)",Demo._tab2.selectWhenE(0,300,2).sortBy(0,1).toObjs())
        Demo._tab2.createIndexAt(0)
        Demo.P("[E] (indexed) 1st row name",Demo._tab2.selectWhenE(1,"Dwi",Demo._tab2.getColIndexBy("name")).toObjs()[0]["name"])
        Demo.P("[E] (indexed) id=6 education.CC",Demo._tab2.id(6)["education"]["CC"])
        Demo.P("[E] (indexed) id=6 tags #2",Demo._tab2.id(6)["tags"][1])
        Demo.P("[E] (indexed) 99th row",Demo._tab2.selectWhenE(1, 99).toObjs())


#ll = '123'
#print(ll[0:0])
Demo.main()