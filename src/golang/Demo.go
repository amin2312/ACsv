package main

import (
	"acsv"
	. "fmt"
	"io/ioutil"
)

/**
 * Tables
 */
var _tab1 *acsv.Table
var _tab2 *acsv.Table

/**
 * Main Entry.
 * @return
 */
func main() {
	var standard_format_text = readToString("release/csvs/standard_format_text.csv")
	_tab1 = acsv.Parse(standard_format_text)
	test_standard_csv_format()
	var enhanced_format_text = readToString("release/csvs/enhanced_format_text.csv")
	_tab2 = acsv.Parse(enhanced_format_text)
	test_enhanced_csv_format()
}

func P(cmd string, o interface{}) {
	Println(cmd)
	nilVal, ok := o.(map[string]interface{})
	if o == nil {
		Println("nil")
	} else if ok && nilVal == nil {
		Println("nil")
	} else {
		Printf("%v", o)
	}
	Println("\n")
}

func test_standard_csv_format() {
	P("select ALL to rows", _tab1.SelectAll().ToRows())
	P("select ALL to objs", _tab1.SelectAll().ToObjs())
	P("select first row", _tab1.SelectFirstRow().ToFirstRow())
	P("select first obj", _tab1.SelectFirstRow().ToFirstObj())
	P("select last row", _tab1.SelectLastRow().ToFirstRow())
	P("select last obj", _tab1.SelectLastRow().ToFirstObj())

	P("selectWhenE (id) = \"2\"", _tab1.SelectWhenE(1, "2", 0, nil).ToFirstObj())
	P("selectWhenE (id) = \"3\" and (id2) = \"21\"", _tab1.SelectWhenE2(1, "3", "21", 1, 0).ToFirstObj())
	P("selectWhenE (id) = \"4\" and (id2) = \"21\" and (id3) = \"200\"", _tab1.SelectWhenE3(1, "4", "21", "200", 2, 1, 0).ToFirstObj())
	P("selectWhenE ALL (id2) = \"20\"", _tab1.SelectWhenE(0, "20", 1, nil).ToObjs())
	P("merge tables", _tab1.Merge(_tab1).SelectAll().ToRows())
}

func test_enhanced_csv_format() {
	P("[E] select ALL to rows", _tab2.SelectAll().ToRows())
	P("[E] select ALL to objs", _tab2.SelectAll().ToObjs())
	P("[E] select first row", _tab2.SelectFirstRow().ToFirstRow())
	P("[E] select first obj", _tab2.SelectFirstRow().ToFirstObj())

	P("[E] select last row", _tab2.SelectLastRow().ToFirstRow())
	P("[E] select last obj", _tab2.SelectLastRow().ToFirstObj())

	P("[E] selectWhenE (id) = 2", _tab2.SelectWhenE(1, 2, 0, nil).ToFirstObj())
	P("[E] selectWhenE (id) = -1", _tab2.SelectWhenE(1, -1, 0, nil).ToFirstObj())
	P("[E] selectWhenE2 (id) = 3 and (id2) = 22", _tab2.SelectWhenE2(1, 3, 22, 1, 0).ToFirstObj())
	P("[E] selectWhenE2 (id) = 3 and (id2) = -1", _tab2.SelectWhenE2(1, 3, -1, 1, 0).ToFirstObj())
	P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = 200", _tab2.SelectWhenE3(1, 4, 22, 200, 2, 1, 0).ToFirstObj())
	P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = -1", _tab2.SelectWhenE3(1, 4, 22, -1, 2, 1, 0).ToFirstObj())
	P("[E] selectWhenE ALL (id2) = 21", _tab2.SelectWhenE(0, 21, 1, nil).ToObjs())
	P("[E] selectWhenE ALL (id2) = -1", _tab2.SelectWhenE(0, -1, 1, nil).ToObjs())

	P("[E] selectWhenG ALL (id2) > 25", _tab2.SelectWhenG(0, false, 25, 1).ToObjs())
	P("[E] selectWhenG ALL (id2) >= 25", _tab2.SelectWhenG(0, true, 25, 1).ToObjs())
	P("[E] selectWhenG ALL (id2) > 30", _tab2.SelectWhenG(0, false, 30, 1).ToObjs())
	P("[E] selectWhenL ALL (id2) < 22", _tab2.SelectWhenL(0, false, 22, 1).ToObjs())
	P("[E] selectWhenL ALL (id2) <= 22", _tab2.SelectWhenL(0, true, 22, 1).ToObjs())
	P("[E] selectWhenL ALL (id2) < 20", _tab2.SelectWhenL(0, true, 20, 1).ToObjs())
	P("[E] selectWhenGreaterAndLess ALL (id2) > 21 and (id2) < 24", _tab2.SelectWhenGreaterAndLess(0, false, false, 21, 24, 1).ToObjs())
	P("[E] selectWhenGreaterAndLess ALL (id2) >= 21 and (id2) <= 24", _tab2.SelectWhenGreaterAndLess(0, true, true, 21, 24, 1).ToObjs())
	P("[E] selectWhenLessOrGreater ALL (id2) < 22 or (id2) > 25", _tab2.SelectWhenLessOrGreater(0, false, false, 22, 25, 1).ToObjs())
	P("[E] selectWhenLessOrGreater ALL (id2) <= 22 or (id2) >= 25", _tab2.SelectWhenLessOrGreater(0, true, true, 22, 25, 1).ToObjs())
	P("[E] selectWhenIn (id) in 3,4,5", _tab2.SelectWhenIn(1, []interface{}{3, 4, 5}, 0).ToObjs())
	P("[E] selectAt rows at 0,1,10", _tab2.SelectAt([]int{0, 1, 10}).ToObjs())

	P("[E] multi selects (id3) = 100 and (id2) < 22", _tab2.SelectWhenE(0, 100, 2, nil).SelectWhenL(0, false, 22, 1).ToObjs())
	P("[E] sort by (id3) = 300 desc (id)", _tab2.SelectWhenE(0, 300, 2, nil).SortBy(0, 1).ToObjs())

	_tab2.CreateIndexAt(0)
	P("[E] (indexed) 1st row name", _tab2.SelectWhenE(1, "Dwi", _tab2.GetColIndexBy("name"), nil).ToObjs()[0]["name"])
	P("[E] (indexed) id=6 education.CC", _tab2.Id(6, 0).(map[string]interface{})["education"].(map[string]interface{})["CC"])
	P("[E] (indexed) id=6 tags #2", _tab2.Id(6, 0).(map[string]interface{})["tags"].([]interface{})[1])
	P("[E] (indexed) 99th row", _tab2.SelectWhenE(1, 99, 0, nil).ToObjs())
}

func readToString(fileName string) string {
	bytes, err := ioutil.ReadFile(fileName)
	if err != nil {
		Printf("%v", err)
	}
	return string(bytes)
}
