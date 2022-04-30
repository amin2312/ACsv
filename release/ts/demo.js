"use strict";
/// <reference path="ACsv.d.ts" />
/**
 * Standard csv format text
 */
var standard_format_text = "id,id2,id3,name,brief\n1,20,100,John,He is a googd man\n2,20,100,\u5F20\u4E09,\"\u4ED6\u662F\u4E00\u4E2A\u597D\u4EBA\n\u6211\u4EEC\u90FD\u559C\u6B22\u4ED6\"\n3,21,100,\u043C\u043E\u0440\u0435,\"\u041E\u043D \u0445\u043E\u0440\u043E\u0448\u0438\u0439 \u0447\u0435\u043B\u043E\u0432\u0435\u043A\n\u043C\u044B \u0432\u0441\u0435 \u043B\u044E\u0431\u0438\u043C \u0435\u0433\u043E\n\u0415\u0433\u043E \u0434\u0435\u0432\u0438\u0437:\n\"\"\u0434\u043E\u0432\u0435\u0440\u044F\u0439 \u0441\u0435\u0431\u0435\"\"\"\n4,21,200,\u0627\u0644\u0634\u0645\u0633,\u0635\u0628\u0627\u062D \u0627\u0644\u062E\u064A\u0631\n5,22,200,\u091A\u0902\u0926\u094D\u0930\u092E\u093E,\u0938\u0941\u0938\u0902\u0927\u094D\u092F\u093E\n6,22,200,\u0E14\u0E32\u0E27,";
/**
 * Enhanced csv format text
 */
var enhanced_format_text = "id:int,id2:int,id3:int,name:string,weight:number,marry:bool,education:json,tags:strings,brief\n1,21,100,John,120.1,true,\"[\"\"AB\"\"]\",\"good,cool\",\"Today is good day\nTomorrow is good day too\"\n2,21,100,\u5F20\u4E09,121.2,false,\"[\"\"CD\"\",\"\"EF\"\"]\",good,\u4ECA\u5929\u662F\u4E2A\u597D\u65E5\u5B50\n3,22,100,\u043C\u043E\u0440\u0435,123.4,true,\"[\"\"GH\"\",\"\"AB\"\",\"\"CD\"\"]\",good,\"\u0421\u0435\u0433\u043E\u0434\u043D\u044F \u0445\u043E\u0440\u043E\u0448\u0438\u0439 \u0434\u0435\u043D\u044C\n\u0417\u0430\u0432\u0442\u0440\u0430 \u0442\u043E\u0436\u0435 \u0445\u043E\u0440\u043E\u0448\u0438\u0439 \u0434\u0435\u043D\u044C\"\n4,22,200,\u0627\u0644\u0634\u0645\u0633,124.5,false,\"{\"\"AA\"\":12}\",strong,\u0635\u0628\u0627\u062D \u0627\u0644\u062E\u064A\u0631\n5,23,200,\u091A\u0902\u0926\u094D\u0930\u092E\u093E,126.7,1,\"{\"\"BB\"\":12}\",strong,\u0938\u0941\u0938\u0902\u0927\u094D\u092F\u093E\n6,23,200,Emilia,,0,\"{\"\"CC\"\":67,\"\"DD\"\":56}\",\"strong,cool\",Hoje \u00E9 um bom dia\n7,24,300,Ay\u015Fe,128.9,0,\"{\"\"EE\"\":68,\"\"FF\"\":56}\",\"strong,cool\",Bug\u00FCn g\u00FCzel bir g\u00FCn\n8,24,300,\u967D\u83DC\u4E43,129.01,,\"{\"\"AC\"\":78,\"\"BD\"\":[90,12]}\",\"height,strong\",\u4ECA\u65E5\u306F\u3044\u3044\u65E5\u3067\u3059\n9,25,300,Dwi,130.12,1,\"{\"\"EF\"\":78,\"\"CF\"\":[90,12]}\",,\"Hari ini adalah hari yang baik\nBesok juga hari yang baik\"\n10,25,400,B\u1EA3o,131.23,1,\"[\"\"BC\"\",{\"\"AT\"\":34}]\",\"thin,good\",\n11,26,400,\uBBFC\uC900,132.34,0,\"[\"\"FG\"\",{\"\"AG\"\":34}]\",\"hot,thin,good\",\uC624\uB298\uC740 \uC88B\uC740 \uB0A0\uC774\uB2E4\n12,26,400,\u0E14\u0E32\u0E27,133.456,0,,,";
/**
 * Tables
 */
var _tab1;
var _tab2;
/**
 * Entry.
 */
function main() {
    _tab1 = acsv.Table.Parse(standard_format_text);
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
