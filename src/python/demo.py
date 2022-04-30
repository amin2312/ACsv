# -*- coding: UTF-8 -*-

import acsv;
import json;
import os;

class Demo:

    def __init__(self):
        srcDir = os.path.dirname(__file__)
        f = open(srcDir + "/../../release/csvs/standard_format_text.csv", "r")
        self._tab1 = acsv.Table.Parse(f.read())
        self.test_standard_csv_format()
        f = open(srcDir + "/../../release/csvs/enhanced_format_text.csv", "r")
        self._tab2 = acsv.Table.Parse(f.read())
        self.test_enhanced_csv_format()

    def P(self, cmd, o):
        print(cmd)
        if (o is None):
            print(str(None))
        else:
            print(o)
            #print(json.dumps(o, ensure_ascii=False))
        print('\n')

    def test_standard_csv_format(self):
        self.P("select ALL to rows",self._tab1.selectAll().toRows())
        self.P("select ALL to objs",self._tab1.selectAll().toObjs())
        self.P("select first row",self._tab1.selectFirstRow().toFirstRow())
        self.P("select first obj",self._tab1.selectFirstRow().toFirstObj())
        self.P("select last row",self._tab1.selectLastRow().toFirstRow())
        self.P("select last obj",self._tab1.selectLastRow().toFirstObj())
        self.P("selectWhenE (id) = \"2\"",self._tab1.selectWhenE(1,"2").toFirstObj())
        self.P("selectWhenE (id) = \"3\" and (id2) = \"21\"",self._tab1.selectWhenE2(1,"3","21").toFirstObj())
        self.P("selectWhenE (id) = \"4\" and (id2) = \"21\" and (id3) = \"200\"",self._tab1.selectWhenE3(1,"4","21","200").toFirstObj())
        self.P("selectWhenE ALL (id2) = \"20\"",self._tab1.selectWhenE(0,"20",1).toObjs())
        self.P("merge tables",self._tab1.merge(self._tab1).selectAll().toRows())

    def test_enhanced_csv_format(self):
        self.P("[E] select ALL to rows",self._tab2.selectAll().toRows())
        self.P("[E] select ALL to objs",self._tab2.selectAll().toObjs())
        self.P("[E] select first row",self._tab2.selectFirstRow().toFirstRow())
        self.P("[E] select first obj",self._tab2.selectFirstRow().toFirstObj())
        self.P("[E] select last row",self._tab2.selectLastRow().toFirstRow())
        self.P("[E] select last obj",self._tab2.selectLastRow().toFirstObj())
        self.P("[E] selectWhenE (id) = 2",self._tab2.selectWhenE(1,2).toFirstObj())
        self.P("[E] selectWhenE (id) = -1",self._tab2.selectWhenE(1,-1).toFirstObj())
        self.P("[E] selectWhenE2 (id) = 3 and (id2) = 22",self._tab2.selectWhenE2(1,3,22).toFirstObj())
        self.P("[E] selectWhenE2 (id) = 3 and (id2) = -1",self._tab2.selectWhenE2(1,3,-1).toFirstObj())
        self.P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = 200",self._tab2.selectWhenE3(1,4,22,200).toFirstObj())
        self.P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = -1",self._tab2.selectWhenE3(1,4,22,-1).toFirstObj())
        self.P("[E] selectWhenE ALL (id2) = 21",self._tab2.selectWhenE(0,21,1).toObjs())
        self.P("[E] selectWhenE ALL (id2) = -1",self._tab2.selectWhenE(0,-1,1).toObjs())
        self.P("[E] selectWhenG ALL (id2) > 25",self._tab2.selectWhenG(0,False,25,1).toObjs())
        self.P("[E] selectWhenG ALL (id2) >= 25",self._tab2.selectWhenG(0,True,25,1).toObjs())
        self.P("[E] selectWhenG ALL (id2) > 30",self._tab2.selectWhenG(0,False,30,1).toObjs())
        self.P("[E] selectWhenL ALL (id2) < 22",self._tab2.selectWhenL(0,False,22,1).toObjs())
        self.P("[E] selectWhenL ALL (id2) <= 22",self._tab2.selectWhenL(0,True,22,1).toObjs())
        self.P("[E] selectWhenL ALL (id2) < 20",self._tab2.selectWhenL(0,True,20,1).toObjs())
        self.P("[E] selectWhenGreaterAndLess ALL (id2) > 21 and (id2) < 24",self._tab2.selectWhenGreaterAndLess(0,False,False,21,24,1).toObjs())
        self.P("[E] selectWhenGreaterAndLess ALL (id2) >= 21 and (id2) <= 24",self._tab2.selectWhenGreaterAndLess(0,True,True,21,24,1).toObjs())
        self.P("[E] selectWhenLessOrGreater ALL (id2) < 22 or (id2) > 25",self._tab2.selectWhenLessOrGreater(0,False,False,22,25,1).toObjs())
        self.P("[E] selectWhenLessOrGreater ALL (id2) <= 22 or (id2) >= 25",self._tab2.selectWhenLessOrGreater(0,True,True,22,25,1).toObjs())
        self.P("[E] selectWhenIn (id) in 3,4,5",self._tab2.selectWhenIn(1,[3, 4, 5]).toObjs())
        self.P("[E] selectAt rows at 0,1,10",self._tab2.selectAt([0, 1, 10]).toObjs())
        self.P("[E] multi selects (id3) = 100 and (id2) < 22",self._tab2.selectWhenE(0,100,2).selectWhenL(0,False,22,1).toObjs())
        self.P("[E] sort by (id3) = 300 desc (id)",self._tab2.selectWhenE(0,300,2).sortBy(0,1).toObjs())
        self._tab2.createIndexAt(0)
        self.P("[E] (indexed) 1st row name",self._tab2.selectWhenE(1,"चंद्रमा",self._tab2.getColIndexBy("name")).toObjs()[0]["name"])
        self.P("[E] (indexed) id=6 education.CC",self._tab2.id(6)["education"]["CC"])
        self.P("[E] (indexed) id=6 tags #2",self._tab2.id(6)["tags"][1])
        self.P("[E] (indexed) 99th row",self._tab2.selectWhenE(1, 99).toObjs())

Demo()