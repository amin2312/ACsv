package ;

import acsv.*;
/**
* Unit Test For ACsv
**/
class Example
{
/**
 * Standard csv format text
 */
public static var standard_format_text = 'id,id2,id3,name,brief
1,20,100,John,He is a googd man
2,20,200,张三,"他是一个好人
我们都喜欢他"
3,20,300,море,"Он хороший человек
мы все любим его
Его девиз:
""доверяй себе"""
4,21,100,الشمس,صباح الخير
5,21,200,चंद्रमा,
6,21,300,,सुसंध्या
7,22,100,,อยากเป็นซุปตาร์
8,22,200,ดาว,';
/**
 * Enhanced csv format text
 */
public static var enhanced_format_text = 'id:int,id2:int,id3:int,name:string,weight:number,marry:bool,education:json,tags:strings,brief
1,20,100,John,120.1,true,"[""MSU""]","good,cool",He is a googd man
2,20,200,张三,121.2,false,"[""JHU"",""MIT""]",good,"他是一个好人
我们都喜欢他"
3,20,300,море,123.4,true,"[""BC"",""HYP"",""NYU""]",strong,"Он хороший человек
мы все любим его
Его девиз:
""доверяй себе"""
4,21,100,الشمس,124.5,false,"{""USC"":12}","strong,cool",صباح الخير
5,21,200,चंद्रमा,126.7,1,"{""UCHI"":34,""UCB"":56}","height,strong",
6,21,300,,127.8,0,"{""UCHI"":78,""UCB"":[90,12]}","thin,good",सुसंध्या
7,22,100,,128.9,1,"[""VT"",{""UCSD"":34}]",,อยากเป็นซุปตาร์
8,22,200,ดาว,129.01,0,,"hot,thin,good",';
    /**
     * 
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
    public static function showTables():Void
    {
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
                var row = csvTable.head[i];
                td.innerText = row.fullName;
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
                    var row = rows[j];
                    td.innerText = row;
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
    public static function print(cmd:String, o:Dynamic):Void
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
        trace(o);
    }

	public static function test_standard_csv_format()
    {
		print('select all to rows', _tab1.selectAll().toROWs());
		print('select all to objs', _tab1.selectAll().toOBJs());
		print('select first row', _tab1.selectFirstRow().toRow());
        print('select first obj', _tab1.selectFirstRow().toObj());
		print('select last row', _tab1.selectLastRow().toRow());
        print('select last obj', _tab1.selectLastRow().toObj());

		print('select [id] = "2"', _tab1.selectOneWhenE("2").toObj());
		print('select [id] = "-1"', _tab1.selectOneWhenE("-1").toObj());
		print('select [id] = "3" and [id2] = "20"', _tab1.selectOneWhenE2("3", "20").toObj());
		print('select [id] = "3" and [id2] = "-1"', _tab1.selectOneWhenE2("3", "-1").toObj());
		print('select [id] = "4" and [id2] = "21" and [id3] = "100"', _tab1.selectOneWhenE3("4", "21", "100").toObj());
		print('select [id] = "4" and [id2] = "21" and [id3] = "-1"', _tab1.selectOneWhenE3("4", "21", "-1").toObj());
		print('select all [id2] = "20"', _tab1.selectAllWhenE("20", 1).toOBJs());
		print('select all [id2] = "-1"', _tab1.selectAllWhenE("-1", 1).toOBJs());
	}

	public static function test_enhanced_csv_format()
    {
		print('[enhanced] select all to rows', _tab2.selectAll().toROWs());
		print('[enhanced] select all to objs', _tab2.selectAll().toOBJs());
		print('[enhanced] select first row', _tab2.selectFirstRow().toRow());
        print('[enhanced] select first obj', _tab2.selectFirstRow().toObj());
		print('[enhanced] select last row', _tab2.selectLastRow().toRow());
        print('[enhanced] select last obj', _tab2.selectLastRow().toObj());

		print('[enhanced] select [id] = 2', _tab2.selectOneWhenE(2).toObj());
		print('[enhanced] select [id] = -1', _tab2.selectOneWhenE(-1).toObj());
		print('[enhanced] select [id] = 3 and [id2] = 20', _tab2.selectOneWhenE2(3, 20).toObj());
		print('[enhanced] select [id] = 3 and [id2] = -1', _tab2.selectOneWhenE2(3, -1).toObj());
		print('[enhanced] select [id] = 4 and [id2] = 21 and [id3] = 100', _tab2.selectOneWhenE3(4, 21, 100).toObj());
		print('[enhanced] select [id] = 4 and [id2] = 21 and [id3] = -1', _tab2.selectOneWhenE3(4, 21, -1).toObj());
		print('[enhanced] select all [id2] = 20', _tab2.selectAllWhenE(20, 1).toOBJs());
		print('[enhanced] select all [id2] = -1', _tab2.selectAllWhenE(-1, 1).toOBJs());
	}
}