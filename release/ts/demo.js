"use strict";
/// <reference path="ACsv.d.ts" />
/**
 * Tables
 */
var _tab1;
var _tab2;
/**
 * Entry.
 */
function main() {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "../../release/csvs/standard_format_text.csv", false);
    xhr.send();
    var standard_format_text = xhr.responseText;
    _tab1 = acsv.Table.Parse(standard_format_text);
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "../../release/csvs/enhanced_format_text.csv", false);
    xhr.send();
    var enhanced_format_text = xhr.responseText;
    _tab2 = acsv.Table.Parse(enhanced_format_text);
    showTable("standard csv format", _tab1);
    test_standard_csv_format();
    showTable("[E] enhanced csv format", _tab2);
    test_enhanced_csv_format();
}
function showTable(fileName, csvTable) {
    var t = document.getElementById('output');
    var tab = document.createElement('table');
    {
        var thead = document.createElement('thead');
        var tr = document.createElement('tr');
        thead.appendChild(tr);
        for (var i = 0; i < csvTable.head.length; i++) {
            var td = document.createElement('td');
            var rowI = csvTable.head[i];
            td.innerText = rowI.fullName;
            tr.appendChild(td);
        }
        tab.appendChild(thead);
    }
    {
        var tbody = document.createElement('tbody');
        for (var i = 0; i < csvTable.body.length; i++) {
            var tr = document.createElement('tr');
            var rows = csvTable.body[i];
            for (var j = 0; j < rows.length; j++) {
                var td = document.createElement('td');
                var rowJ = rows[j];
                td.innerText = rowJ;
                tr.appendChild(td);
            }
            tbody.appendChild(tr);
        }
        tab.appendChild(tbody);
    }
    {
        var tfoot = document.createElement('tfoot');
        var tr = document.createElement('tr');
        var td = document.createElement('td');
        td.colSpan = csvTable.head.length;
        td.innerText = fileName;
        tr.appendChild(td);
        tfoot.appendChild(tr);
        tab.appendChild(tfoot);
    }
    t.appendChild(tab);
}
function P(cmd, o) {
    var t = document.getElementById('output');
    var div = document.createElement('div');
    var span = document.createElement('span');
    span.innerHTML = cmd.replace('[E]', '<span class="E">[E]</span>');
    div.appendChild(span);
    div.title = JSON.stringify(o, null, '\t');
    div.innerHTML += JSON.stringify(o);
    t.appendChild(div);
    console.log(cmd);
    if (o == null) // fix some language's bug
     {
        console.log(null);
    }
    else {
        console.log(o);
    }
}
function test_standard_csv_format() {
    P('select ALL to rows', _tab1.selectAll().toRows());
    P('select ALL to objs', _tab1.selectAll().toObjs());
    P('select first row', _tab1.selectFirstRow().toFirstRow());
    P('select first obj', _tab1.selectFirstRow().toFirstObj());
    P('select last row', _tab1.selectLastRow().toFirstRow());
    P('select last obj', _tab1.selectLastRow().toFirstObj());
    P('selectWhenE (id) = "2"', _tab1.selectWhenE(1, "2").toFirstObj());
    P('selectWhenE (id) = "3" and (id2) = "21"', _tab1.selectWhenE2(1, "3", "21").toFirstObj());
    P('selectWhenE (id) = "4" and (id2) = "21" and (id3) = "200"', _tab1.selectWhenE3(1, "4", "21", "200").toFirstObj());
    P('selectWhenE ALL (id2) = "20"', _tab1.selectWhenE(0, "20", 1).toObjs());
    P('merge tables', _tab1.merge(_tab1).selectAll().toRows());
}
function test_enhanced_csv_format() {
    P('[E] select ALL to rows', _tab2.selectAll().toRows());
    P('[E] select ALL to objs', _tab2.selectAll().toObjs());
    P('[E] select first row', _tab2.selectFirstRow().toFirstRow());
    P('[E] select first obj', _tab2.selectFirstRow().toFirstObj());
    P('[E] select last row', _tab2.selectLastRow().toFirstRow());
    P('[E] select last obj', _tab2.selectLastRow().toFirstObj());
    P('[E] selectWhenE (id) = 2', _tab2.selectWhenE(1, 2).toFirstObj());
    P('[E] selectWhenE (id) = -1', _tab2.selectWhenE(1, -1).toFirstObj());
    P('[E] selectWhenE2 (id) = 3 and (id2) = 22', _tab2.selectWhenE2(1, 3, 22).toFirstObj());
    P('[E] selectWhenE2 (id) = 3 and (id2) = -1', _tab2.selectWhenE2(1, 3, -1).toFirstObj());
    P('[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = 200', _tab2.selectWhenE3(1, 4, 22, 200).toFirstObj());
    P('[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = -1', _tab2.selectWhenE3(1, 4, 22, -1).toFirstObj());
    P('[E] selectWhenE ALL (id2) = 21', _tab2.selectWhenE(0, 21, 1).toObjs());
    P('[E] selectWhenE ALL (id2) = -1', _tab2.selectWhenE(0, -1, 1).toObjs());
    P('[E] selectWhenG ALL (id2) > 25', _tab2.selectWhenG(0, false, 25, 1).toObjs());
    P('[E] selectWhenG ALL (id2) >= 25', _tab2.selectWhenG(0, true, 25, 1).toObjs());
    P('[E] selectWhenG ALL (id2) > 30', _tab2.selectWhenG(0, false, 30, 1).toObjs());
    P('[E] selectWhenL ALL (id2) < 22', _tab2.selectWhenL(0, false, 22, 1).toObjs());
    P('[E] selectWhenL ALL (id2) <= 22', _tab2.selectWhenL(0, true, 22, 1).toObjs());
    P('[E] selectWhenL ALL (id2) < 20', _tab2.selectWhenL(0, true, 20, 1).toObjs());
    P('[E] selectWhenGreaterAndLess ALL (id2) > 21 and (id2) < 24', _tab2.selectWhenGreaterAndLess(0, false, false, 21, 24, 1).toObjs());
    P('[E] selectWhenGreaterAndLess ALL (id2) >= 21 and (id2) <= 24', _tab2.selectWhenGreaterAndLess(0, true, true, 21, 24, 1).toObjs());
    P('[E] selectWhenLessOrGreater ALL (id2) < 22 or (id2) > 25', _tab2.selectWhenLessOrGreater(0, false, false, 22, 25, 1).toObjs());
    P('[E] selectWhenLessOrGreater ALL (id2) <= 22 or (id2) >= 25', _tab2.selectWhenLessOrGreater(0, true, true, 22, 25, 1).toObjs());
    P('[E] selectWhenIn (id) in 3,4,5', _tab2.selectWhenIn(1, [3, 4, 5]).toObjs());
    P('[E] selectAt rows at 0,1,10', _tab2.selectAt([0, 1, 10]).toObjs());
    P('[E] multi selects (id3) = 100 and (id2) < 22', _tab2.selectWhenE(0, 100, 2).selectWhenL(0, false, 22, 1).toObjs());
    P('[E] sort by (id3) = 300 desc (id)', _tab2.selectWhenE(0, 300, 2).sortBy(0, 1).toObjs());
    _tab2.createIndexAt(0);
    P("[E] (indexed) 1st row name", _tab2.selectWhenE(1, 'Dwi', _tab2.getColIndexBy('name')).toObjs()[0].name);
    P("[E] (indexed) id=6 education.CC", _tab2.id(6).education.CC);
    P("[E] (indexed) id=6 tags #2", _tab2.id(6).tags[1]);
    P('[E] (indexed) 99th row', _tab2.selectWhenE(1, 99).toObjs());
}
main();
