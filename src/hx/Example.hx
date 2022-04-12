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
public static var enhanced_format_text = 'id:int,id2:int,id3:int,name:string,money:number,marry:bool,education:json,tags:strings,brief
1,20,100,John,101.1,true,"[""MSU""]","good,cool",He is a googd man
2,20,200,张三,102.2,false,"[""JHU"",""MIT""]",good,"他是一个好人
我们都喜欢他"
3,20,300,море,103.4,true,"[""BC"",""HYP"",""NYU""]",strong,"Он хороший человек
мы все любим его
Его девиз:
""доверяй себе"""
4,21,100,الشمس,104.8,false,"{""USC"":2020}","strong,cool",صباح الخير
5,21,200,चंद्रमा,105.16,1,"{""UCHI"":2020,""UCB"":2021}","height,strong",
6,21,300,,106.32,0,"{""UCHI"":2020,""UCB"":[2021,2022]}","thin,good",सुसंध्या
7,22,100,,107.64,1,"[""VT"",{""UCSD"":2020}]",,อยากเป็นซุปตาร์
8,22,200,ดาว,108.128,0,,"hot,thin,good",';
    /**
     * Main Entry.
     */
    public static function main()
    {
        test_common_usage();
        test_standard_csv_format();
        test_enhanced_csv_format();
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
	public static function test_common_usage()
    {
		var tab1 = Table.Parse(standard_format_text);
		print('select all to rows', tab1.selectAll().toROWs());
		print('select all to objs', tab1.selectAll().toOBJs());
		print('select first row', tab1.selectFirstRow().toRow());
        print('select first obj', tab1.selectFirstRow().toObj());
		print('select last row', tab1.selectLastRow().toRow());
        print('select last obj', tab1.selectLastRow().toObj());

		var tab2 = Table.Parse(enhanced_format_text);
		print('[enhanced] select all to rows', tab2.selectAll().toROWs());
		print('[enhanced] select all to objs', tab2.selectAll().toOBJs());
		print('[enhanced] select first row', tab2.selectFirstRow().toRow());
        print('[enhanced] select first obj', tab2.selectFirstRow().toObj());
		print('[enhanced] select last row', tab2.selectLastRow().toRow());
        print('[enhanced] select last obj', tab2.selectLastRow().toObj());
    }
	public static function test_standard_csv_format()
    {
		var table = Table.Parse(standard_format_text);
		print('select [id] = "2"', table.selectOneWhenE("2").toRow());
		print('select [id] = "-1"', table.selectOneWhenE("-1").toRow());
		print('select [id] = "3" and [id2] = "20"', table.selectOneWhenE2("3", "20").toRow());
		print('select [id] = "3" and [id2] = "-1"', table.selectOneWhenE2("3", "-1").toRow());
		print('select [id] = "4" and [id2] = "21" and [id3] = "100"', table.selectOneWhenE3("4", "21", "100").toRow());
		print('select [id] = "4" and [id2] = "21" and [id3] = "-1"', table.selectOneWhenE3("4", "21", "-1").toRow());
		print('select all [id2] = "20"', table.selectAllWhenE("20", 1).toROWs());
		print('select all [id2] = "-1"', table.selectAllWhenE("-1", 1).toROWs());
	}

	public static function test_enhanced_csv_format()
    {
		var table = Table.Parse(enhanced_format_text);
		print('[enhanced] select [id] = 2', table.selectOneWhenE(2).toRow());
		print('[enhanced] select [id] = -1', table.selectOneWhenE(-1).toRow());
		print('[enhanced] select [id] = 3 and [id2] = 20', table.selectOneWhenE2(3, 20).toRow());
		print('[enhanced] select [id] = 3 and [id2] = -1', table.selectOneWhenE2(3, -1).toRow());
		print('[enhanced] select [id] = 4 and [id2] = 21 and [id3] = 100', table.selectOneWhenE3(4, 21, 100).toRow());
		print('[enhanced] select [id] = 4 and [id2] = 21 and [id3] = -1', table.selectOneWhenE3(4, 21, -1).toRow());
		print('[enhanced] select all [id2] = 20', table.selectAllWhenE(20, 1).toROWs());
		print('[enhanced] select all [id2] = -1', table.selectAllWhenE(-1, 1).toROWs());
	}
}