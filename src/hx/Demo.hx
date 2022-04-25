package ;

import acsv.*;

class Demo
{
/**
 * Standard csv format text
 */
public static var standard_format_text = 'id,id2,id3,name,brief
1,20,100,John,He is a googd man
2,20,100,张三,"他是一个好人
我们都喜欢他"
3,21,100,море,"Он хороший человек
мы все любим его
Его девиз:
""доверяй себе"""
4,21,200,الشمس,صباح الخير
5,22,200,चंद्रमा,सुसंध्या
6,22,200,ดาว,';
/**
 * Enhanced csv format text
 */
public static var enhanced_format_text = 'id:int,id2:int,id3:int,name:string,weight:number,marry:bool,education:json,tags:strings,brief
1,21,100,John,120.1,true,"[""AB""]","good,cool","Today is good day
Tomorrow is good day too"
2,21,100,张三,121.2,false,"[""CD"",""EF""]",good,今天是个好日子
3,22,100,море,123.4,true,"[""GH"",""AB"",""CD""]",good,"Сегодня хороший день
Завтра тоже хороший день"
4,22,200,الشمس,124.5,false,"{""AA"":12}",strong,صباح الخير
5,23,200,चंद्रमा,126.7,1,"{""BB"":12}",strong,सुसंध्या
6,23,200,Emilia,,0,"{""CC"":34,""DD"":56}","strong,cool",Hoje é um bom dia
7,24,300,Ayşe,128.9,0,"{""EE"":34,""FF"":56}","strong,cool",Bugün güzel bir gün
8,24,300,陽菜乃,129.01,,"{""AC"":78,""BD"":[90,12]}","height,strong",今日はいい日です
9,25,300,Dwi,130.12,1,"{""EF"":78,""CF"":[90,12]}",,"Hari ini adalah hari yang baik
Besok juga hari yang baik"
10,25,400,Bảo,131.23,1,"[""BC"",{""AT"":34}]","thin,good",
11,26,400,민준,132.34,0,"[""FG"",{""AG"":34}]","hot,thin,good",오늘은 좋은 날이다
12,26,400,ดาว,133.456,0,,,';
    /**
     * Tables
     */
    private static var _tab1:Table;
    private static var _tab2:Table;
    /**
     * Main Entry.
     */
    public static function main()
    {
		_tab1 = Table.Parse(standard_format_text);
		_tab2 = Table.Parse(enhanced_format_text);

        showTable("standard csv format", _tab1);
        test_standard_csv_format();
        showTable("enhanced csv format", _tab2);
        test_enhanced_csv_format();
    }
    
    private static function showTable(fileName:String, csvTable:Table):Void
    {
        #if js
        var t = js.Browser.document.getElementById('output');
        var tab = js.Browser.document.createElement('table');
        {
            var thead = js.Browser.document.createElement('thead');
            var tr =  js.Browser.document.createElement('tr');
            thead.appendChild(tr);
            for(i in 0...csvTable.head.length)
            {
                var td =  js.Browser.document.createElement('td');
                var rowI = csvTable.head[i];
                td.innerText = rowI.fullName;
                tr.appendChild(td);
            }
            tab.appendChild(thead);
        }
        {
            var tbody = js.Browser.document.createElement('tbody');
            for(i in 0...csvTable.body.length)
            {
                var tr =  js.Browser.document.createElement('tr');
                var rows = csvTable.body[i];
                for(j in 0...rows.length)
                {
                    var td =  js.Browser.document.createElement('td');
                    var rowJ = rows[j];
                    td.innerText = rowJ;
                    tr.appendChild(td);
                }
                tbody.appendChild(tr);
            }
            tab.appendChild(tbody);
        }
        {
            var tfoot = js.Browser.document.createElement('tfoot');
            var tr =  js.Browser.document.createElement('tr');
            var td:js.html.TableCellElement = untyped js.Browser.document.createElement('td');
            td.colSpan = csvTable.head.length;
            td.innerText = fileName;
            tr.appendChild(td);
            tfoot.appendChild(tr);
            tab.appendChild(tfoot);
        }
        t.appendChild(tab);
        #end
        
    }
    public static function P(cmd:String, o:Dynamic):Void
    {
        #if js
        var t = js.Browser.document.getElementById('output');
        var div = js.Browser.document.createElement('div');
        var span = js.Browser.document.createElement('span');
        span.innerHTML = StringTools.replace(cmd, '[enhanced]', '<span class="E">[enhanced]</span>');
        div.appendChild(span);
        div.title = haxe.Json.stringify(o, null, '\t');
        div.innerHTML += haxe.Json.stringify(o);
        t.appendChild(div);
        #end
        trace(cmd);
        if (o == null) // fix some language's bug
        {
            trace(null);
        }
        else
        {
            trace(o);
        }
    }

	public static function test_standard_csv_format()
    {
		P('select all to rows', _tab1.selectAll().toRows());
		P('select all to objs', _tab1.selectAll().toObjs());
		P('select first row', _tab1.selectFirstRow().toFirstRow());
        P('select first obj', _tab1.selectFirstRow().toFirstObj());
		P('select last row', _tab1.selectLastRow().toFirstRow());
        P('select last obj', _tab1.selectLastRow().toFirstObj());

		P('select [id] = "2"', _tab1.selectWhenE(1, "2").toFirstObj());
		P('select [id] = "-1"', _tab1.selectWhenE(1, "-1").toFirstObj());
		P('select [id] = "3" and [id2] = "21"', _tab1.selectWhenE2(1, "3", "21").toFirstObj());
		P('select [id] = "3" and [id2] = "-1"', _tab1.selectWhenE2(1, "3", "-1").toFirstObj());
		P('select [id] = "4" and [id2] = "21" and [id3] = "200"', _tab1.selectWhenE3(1, "4", "21", "200").toFirstObj());
		P('select [id] = "4" and [id2] = "21" and [id3] = "-1"', _tab1.selectWhenE3(1, "4", "21", "-1").toFirstObj());
		P('select all [id2] = "20"', _tab1.selectWhenE(0, "20", 1).toObjs());
		P('select all [id2] = "-1"', _tab1.selectWhenE(0, "-1", 1).toObjs());
	}

	public static function test_enhanced_csv_format()
    {
		P('[enhanced] select all to rows', _tab2.selectAll().toRows());
		P('[enhanced] select all to objs', _tab2.selectAll().toObjs());
		P('[enhanced] select first row', _tab2.selectFirstRow().toFirstRow());
        P('[enhanced] select first obj', _tab2.selectFirstRow().toFirstObj());
		P('[enhanced] select last row', _tab2.selectLastRow().toFirstRow());
        P('[enhanced] select last obj', _tab2.selectLastRow().toFirstObj());

		P('[enhanced] select [id] = 2', _tab2.selectWhenE(1, 2).toFirstObj());
		P('[enhanced] select [id] = -1', _tab2.selectWhenE(1, -1).toFirstObj());
		P('[enhanced] select [id] = 3 and [id2] = 22', _tab2.selectWhenE2(1, 3, 22).toFirstObj());
		P('[enhanced] select [id] = 3 and [id2] = -1', _tab2.selectWhenE2(1, 3, -1).toFirstObj());
		P('[enhanced] select [id] = 4 and [id2] = 22 and [id3] = 200', _tab2.selectWhenE3(1, 4, 22, 200).toFirstObj());
		P('[enhanced] select [id] = 4 and [id2] = 22 and [id3] = -1', _tab2.selectWhenE3(1, 4, 22, -1).toFirstObj());
		P('[enhanced] select all [id2] = 21', _tab2.selectWhenE(0, 21, 1).toObjs());
		P('[enhanced] select all [id2] = -1', _tab2.selectWhenE(0, -1, 1).toObjs());

		P('[enhanced] select all [id2] > 25', _tab2.selectWhenG(0, false, 25, 1).toObjs());
		P('[enhanced] select all [id2] >= 25', _tab2.selectWhenG(0, true, 25, 1).toObjs());
		P('[enhanced] select all [id2] > 30', _tab2.selectWhenG(0, false, 30, 1).toObjs());
		P('[enhanced] select all [id2] < 22', _tab2.selectWhenL(0, false, 22, 1).toObjs());
		P('[enhanced] select all [id2] <= 22', _tab2.selectWhenL(0, true, 22, 1).toObjs());
		P('[enhanced] select all [id2] < 20', _tab2.selectWhenL(0, true, 20, 1).toObjs());
        P('[enhanced] select all [id2] > 21 and [id2] < 24', _tab2.selectWhenGreaterAndLess(0, false, false, 21, 24, 1).toObjs());
        P('[enhanced] select all [id2] >= 21 and [id2] <= 24', _tab2.selectWhenGreaterAndLess(0, true, true, 21, 24, 1).toObjs());
        P('[enhanced] select all [id2] < 22 or [id2] > 25', _tab2.selectWhenLessOrGreater(0, false, false, 22, 25, 1).toObjs());
        P('[enhanced] select all [id2] <= 22 or [id2] >= 25', _tab2.selectWhenLessOrGreater(0, true, true, 22, 25, 1).toObjs());
        
		P('[enhanced] multi select all [id3] = 100 and [id2] < 22', _tab2.selectWhenE(0, 100, 2).selectWhenL(0, false, 22, 1).toObjs());

        _tab2.createIndexAt(0);
		P('[enhanced] 9th row name', _tab2.selectWhenE(1, 9).toObjs()[0].name);
		P('[enhanced] 99th row name', _tab2.selectWhenE(1, 99).toObjs());
	}
}