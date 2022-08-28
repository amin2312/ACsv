// Generated by Haxe 3.4.7
(function ($hx_exports) { "use strict";
$hx_exports["acsv"] = $hx_exports["acsv"] || {};
var Demo = function() { };
Demo.main = function() {
	var xhr = new XMLHttpRequest();
	xhr.open("GET","../../release/csvs/standard_format_text.csv",false);
	xhr.send();
	var standard_format_text = xhr.responseText;
	Demo._tab1 = acsv_Table.Parse(standard_format_text);
	var xhr1 = new XMLHttpRequest();
	xhr1.open("GET","../../release/csvs/enhanced_format_text.csv",false);
	xhr1.send();
	var enhanced_format_text = xhr1.responseText;
	Demo._tab2 = acsv_Table.Parse(enhanced_format_text);
	Demo.showTable("standard csv format",Demo._tab1);
	Demo.test_standard_csv_format();
	Demo.showTable("[E] enhanced csv format",Demo._tab2);
	Demo.test_enhanced_csv_format();
};
Demo.showTable = function(fileName,csvTable) {
	var t = window.document.getElementById("output");
	var tab = window.document.createElement("table");
	var thead = window.document.createElement("thead");
	var tr = window.document.createElement("tr");
	thead.appendChild(tr);
	var _g1 = 0;
	var _g = csvTable.head.length;
	while(_g1 < _g) {
		var i = _g1++;
		var td = window.document.createElement("td");
		var rowI = csvTable.head[i];
		td.innerText = rowI.fullName;
		tr.appendChild(td);
	}
	tab.appendChild(thead);
	var tbody = window.document.createElement("tbody");
	var _g11 = 0;
	var _g2 = csvTable.body.length;
	while(_g11 < _g2) {
		var i1 = _g11++;
		var tr1 = window.document.createElement("tr");
		var rows = csvTable.body[i1];
		var _g3 = 0;
		var _g21 = rows.length;
		while(_g3 < _g21) {
			var j = _g3++;
			var td1 = window.document.createElement("td");
			var rowJ = rows[j];
			td1.innerText = rowJ;
			tr1.appendChild(td1);
		}
		tbody.appendChild(tr1);
	}
	tab.appendChild(tbody);
	var tfoot = window.document.createElement("tfoot");
	var tr2 = window.document.createElement("tr");
	var td2 = window.document.createElement("td");
	td2.colSpan = csvTable.head.length;
	td2.innerText = fileName;
	tr2.appendChild(td2);
	tfoot.appendChild(tr2);
	tab.appendChild(tfoot);
	t.appendChild(tab);
};
Demo.P = function(cmd,o) {
	var t = window.document.getElementById("output");
	var div = window.document.createElement("div");
	var span = window.document.createElement("span");
	span.innerHTML = StringTools.replace(cmd,"[E]","<span class=\"E\">[E]</span>");
	div.appendChild(span);
	div.title = JSON.stringify(o,null,"\t");
	div.innerHTML += JSON.stringify(o);
	t.appendChild(div);
	console.log(cmd);
	if(o == null) {
		console.log(null);
	} else {
		console.log(o);
	}
};
Demo.test_standard_csv_format = function() {
	Demo.P("select ALL to rows",Demo._tab1.selectAll().toRows());
	Demo.P("select ALL to objs",Demo._tab1.selectAll().toObjs());
	Demo.P("select first row",Demo._tab1.selectFirstRow().toFirstRow());
	Demo.P("select first obj",Demo._tab1.selectFirstRow().toFirstObj());
	Demo.P("select last row",Demo._tab1.selectLastRow().toFirstRow());
	Demo.P("select last obj",Demo._tab1.selectLastRow().toFirstObj());
	Demo.P("selectWhenE (id) = \"2\"",Demo._tab1.selectWhenE(1,"2").toFirstObj());
	Demo.P("selectWhenE (id) = \"3\" and (id2) = \"21\"",Demo._tab1.selectWhenE2(1,"3","21").toFirstObj());
	Demo.P("selectWhenE (id) = \"4\" and (id2) = \"21\" and (id3) = \"200\"",Demo._tab1.selectWhenE3(1,"4","21","200").toFirstObj());
	Demo.P("selectWhenE ALL (id2) = \"20\"",Demo._tab1.selectWhenE(0,"20",1).toObjs());
	Demo.P("merge tables",Demo._tab1.merge(Demo._tab1).selectAll().toRows());
};
Demo.test_enhanced_csv_format = function() {
	Demo.P("[E] select ALL to rows",Demo._tab2.selectAll().toRows());
	Demo.P("[E] select ALL to objs",Demo._tab2.selectAll().toObjs());
	Demo.P("[E] select first row",Demo._tab2.selectFirstRow().toFirstRow());
	Demo.P("[E] select first obj",Demo._tab2.selectFirstRow().toFirstObj());
	Demo.P("[E] select last row",Demo._tab2.selectLastRow().toFirstRow());
	Demo.P("[E] select last obj",Demo._tab2.selectLastRow().toFirstObj());
	Demo.P("[E] selectWhenE (id) = 2",Demo._tab2.selectWhenE(1,2).toFirstObj());
	Demo.P("[E] selectWhenE (id) = -1",Demo._tab2.selectWhenE(1,-1).toFirstObj());
	Demo.P("[E] selectWhenE2 (id) = 3 and (id2) = 22",Demo._tab2.selectWhenE2(1,3,22).toFirstObj());
	Demo.P("[E] selectWhenE2 (id) = 3 and (id2) = -1",Demo._tab2.selectWhenE2(1,3,-1).toFirstObj());
	Demo.P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = 200",Demo._tab2.selectWhenE3(1,4,22,200).toFirstObj());
	Demo.P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = -1",Demo._tab2.selectWhenE3(1,4,22,-1).toFirstObj());
	Demo.P("[E] selectWhenE ALL (id2) = 21",Demo._tab2.selectWhenE(0,21,1).toObjs());
	Demo.P("[E] selectWhenE ALL (id2) = -1",Demo._tab2.selectWhenE(0,-1,1).toObjs());
	Demo.P("[E] selectWhenG ALL (id2) > 25",Demo._tab2.selectWhenG(0,false,25,1).toObjs());
	Demo.P("[E] selectWhenG ALL (id2) >= 25",Demo._tab2.selectWhenG(0,true,25,1).toObjs());
	Demo.P("[E] selectWhenG ALL (id2) > 30",Demo._tab2.selectWhenG(0,false,30,1).toObjs());
	Demo.P("[E] selectWhenL ALL (id2) < 22",Demo._tab2.selectWhenL(0,false,22,1).toObjs());
	Demo.P("[E] selectWhenL ALL (id2) <= 22",Demo._tab2.selectWhenL(0,true,22,1).toObjs());
	Demo.P("[E] selectWhenL ALL (id2) < 20",Demo._tab2.selectWhenL(0,true,20,1).toObjs());
	Demo.P("[E] selectWhenGreaterAndLess ALL (id2) > 21 and (id2) < 24",Demo._tab2.selectWhenGreaterAndLess(0,false,false,21,24,1).toObjs());
	Demo.P("[E] selectWhenGreaterAndLess ALL (id2) >= 21 and (id2) <= 24",Demo._tab2.selectWhenGreaterAndLess(0,true,true,21,24,1).toObjs());
	Demo.P("[E] selectWhenLessOrGreater ALL (id2) < 22 or (id2) > 25",Demo._tab2.selectWhenLessOrGreater(0,false,false,22,25,1).toObjs());
	Demo.P("[E] selectWhenLessOrGreater ALL (id2) <= 22 or (id2) >= 25",Demo._tab2.selectWhenLessOrGreater(0,true,true,22,25,1).toObjs());
	Demo.P("[E] selectWhenIn (id) in 3,4,5",Demo._tab2.selectWhenIn(1,[3,4,5]).toObjs());
	Demo.P("[E] selectAt rows at 0,1,10",Demo._tab2.selectAt([0,1,10]).toObjs());
	Demo.P("[E] multi selects (id3) = 100 and (id2) < 22",Demo._tab2.selectWhenE(0,100,2).selectWhenL(0,false,22,1).toObjs());
	Demo.P("[E] sort by (id3) = 300 desc (id)",Demo._tab2.selectWhenE(0,300,2).sortBy(0,1).toObjs());
	Demo._tab2.createIndexAt(0);
	Demo.P("[E] (indexed) 1st row name",Demo._tab2.selectWhenE(1,"Dwi",Demo._tab2.getColIndexBy("name")).toObjs()[0].name);
	Demo.P("[E] (indexed) id=6 education.CC",Demo._tab2.id(6).education.CC);
	Demo.P("[E] (indexed) id=6 tags #2",Demo._tab2.id(6).tags[1]);
	Demo.P("[E] (indexed) 99th row",Demo._tab2.selectWhenE(1,99).toObjs());
};
var StringTools = function() { };
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
var acsv_Field = $hx_exports["acsv"]["Field"] = function() {
};
var acsv_Table = $hx_exports["acsv"]["Table"] = function() {
	this._selector = null;
	this._indexSet = { };
	this.body = [];
	this.head = [];
	this.content = null;
};
acsv_Table.Parse = function(content,filedSeparator,filedDelimiter) {
	if(filedDelimiter == null) {
		filedDelimiter = "\"";
	}
	if(filedSeparator == null) {
		filedSeparator = ",";
	}
	var table = acsv_Table.arrayToRows(acsv_Table.textToArray(content,filedSeparator,filedDelimiter));
	table.content = content;
	return table;
};
acsv_Table.textToArray = function(text,FS,FD) {
	if(FD == null) {
		FD = "\"";
	}
	if(FS == null) {
		FS = ",";
	}
	if(text.charCodeAt(0) == 0xFEFF) {
		text = text.substring(1);
	}
	var FDs = FD + FD;
	var arr = [];
	var maxLen = text.length;
	var ptr = text;
	var ptrPos = 0;
	while(true) {
		var curLen = maxLen - ptrPos;
		var cellIndexA = 0;
		var cellIndexB = 0;
		var cells = [];
		var cell = null;
		var cc = null;
		while(cellIndexB < curLen) {
			cellIndexA = cellIndexB;
			cc = ptr.charAt(ptrPos + cellIndexB);
			if(cc == "\r" && ptr.charAt(ptrPos + cellIndexB + 1) == "\n") {
				cellIndexB += 2;
				break;
			}
			if(cc == "\n") {
				++cellIndexB;
				break;
			}
			if(cc == FS) {
				cell = "";
				var nextPos = ptrPos + cellIndexB + 1;
				if(nextPos < maxLen) {
					cc = ptr.charAt(nextPos);
				} else {
					cc = "\n";
				}
				if(cellIndexA == 0 || cc == FS || cc == "\n") {
					++cellIndexB;
					cells.push("");
				} else if(cc == "\r" && ptr.charAt(ptrPos + cellIndexB + 2) == "\n") {
					cellIndexB += 2;
					cells.push("");
				} else {
					++cellIndexB;
				}
			} else if(cc == FD) {
				++cellIndexB;
				while(true) {
					cellIndexB = ptr.indexOf(FD,ptrPos + cellIndexB);
					if(cellIndexB == -1) {
						console.log("[ACsv] Invalid Double Quote");
						return null;
					}
					cellIndexB -= ptrPos;
					var nextPos1 = ptrPos + cellIndexB + 1;
					if(nextPos1 < maxLen) {
						if(ptr.charAt(nextPos1) == FD) {
							cellIndexB += 2;
							continue;
						}
					}
					break;
				}
				cell = ptr.substring(ptrPos + cellIndexA + 1,ptrPos + cellIndexB);
				cell = StringTools.replace(cell,FDs,FD);
				cells.push(cell);
				++cellIndexB;
			} else {
				var indexA = ptr.indexOf(FS,ptrPos + cellIndexB);
				if(indexA == -1) {
					indexA = curLen;
				} else {
					indexA -= ptrPos;
				}
				var indexB = ptr.indexOf("\r\n",ptrPos + cellIndexB);
				if(indexB == -1) {
					indexB = ptr.indexOf("\n",ptrPos + cellIndexB);
				}
				if(indexB == -1) {
					indexB = curLen;
				} else {
					indexB -= ptrPos;
				}
				cellIndexB = indexA;
				if(indexB < indexA) {
					cellIndexB = indexB;
				}
				cell = ptr.substring(ptrPos + cellIndexA,ptrPos + cellIndexB);
				cells.push(cell);
			}
		}
		arr.push(cells);
		ptrPos += cellIndexB;
		if(ptrPos >= maxLen) {
			break;
		}
	}
	return arr;
};
acsv_Table.arrayToRows = function(arr) {
	var rawHead = arr.shift();
	var srcBody = arr;
	var newHead = [];
	var _g1 = 0;
	var _g = rawHead.length;
	while(_g1 < _g) {
		var i = _g1++;
		var fullName = rawHead[i];
		var parts = fullName.split(":");
		var filed = new acsv_Field();
		filed.fullName = fullName;
		filed.name = parts[0];
		filed.type = parts[1];
		newHead.push(filed);
	}
	var _g11 = 0;
	var _g2 = srcBody.length;
	while(_g11 < _g2) {
		var i1 = _g11++;
		var row = srcBody[i1];
		var _g3 = 0;
		var _g21 = row.length;
		while(_g3 < _g21) {
			var j = _g3++;
			var cell = row[j];
			var newVal = cell;
			var isEmptyCell = cell == null || cell == "";
			var ft = newHead[j].type;
			if(ft == "bool") {
				if(isEmptyCell || cell == "false" || cell == "0") {
					newVal = false;
				} else {
					newVal = true;
				}
			} else if(ft == "int") {
				if(isEmptyCell) {
					newVal = 0;
				} else {
					newVal = parseInt(cell);
				}
			} else if(ft == "number") {
				if(isEmptyCell) {
					newVal = 0.0;
				} else {
					newVal = parseFloat(cell);
				}
			} else if(ft == "json") {
				if(isEmptyCell) {
					newVal = null;
				} else {
					var cc = cell.charAt(0);
					if(!(cc == "[" || cc == "{")) {
						console.log("[ACsv] Invalid json format:" + newHead[j].name + "," + cell);
						return null;
					}
					newVal = cell;
				}
			} else if(ft == "strings") {
				if(isEmptyCell) {
					newVal = "[]";
				} else {
					newVal = "[\"" + cell.split(",").join("\",\"") + "\"]";
				}
			}
			row[j] = newVal;
		}
		srcBody[i1] = row;
	}
	var table = new acsv_Table();
	table.head = newHead;
	table.body = srcBody;
	return table;
};
acsv_Table.prototype = {
	merge: function(b) {
		this.body = this.body.concat(b.body);
		var index = b.content.indexOf("\r\n");
		if(index == -1) {
			index = b.content.indexOf("\n");
		}
		var c = b.content.substring(index);
		this.content += c;
		return this;
	}
	,createIndexAt: function(colIndex) {
		var m = { };
		var _g1 = 0;
		var _g = this.body.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = this.body[i];
			var key = row[colIndex];
			m[key] = row;
		}
		this._indexSet[colIndex] = m;
	}
	,getColIndexBy: function(name) {
		var _g1 = 0;
		var _g = this.head.length;
		while(_g1 < _g) {
			var i = _g1++;
			var field = this.head[i];
			if(field.name == name) {
				return i;
			}
		}
		return -1;
	}
	,id: function(value,colIndex) {
		if(colIndex == null) {
			colIndex = 0;
		}
		return this.selectWhenE(1,value,colIndex).toFirstObj();
	}
	,sortBy: function(colIndex,sortType) {
		var l = this._selector.length;
		var _g1 = 0;
		var _g = l;
		while(_g1 < _g) {
			var i = _g1++;
			var _g3 = 0;
			var _g2 = l - 1;
			while(_g3 < _g2) {
				var j = _g3++;
				var ok = false;
				var a = this._selector[j][colIndex];
				var b = this._selector[j + 1][colIndex];
				if(sortType == 0 && a > b) {
					ok = true;
				} else if(sortType == 1 && a < b) {
					ok = true;
				}
				if(ok) {
					var temp = this._selector[j];
					this._selector[j] = this._selector[j + 1];
					this._selector[j + 1] = temp;
				}
			}
		}
		return this;
	}
	,getCurrentSelector: function() {
		return this._selector;
	}
	,fmtRow: function(row) {
		var obj = [];
		var _g1 = 0;
		var _g = this.head.length;
		while(_g1 < _g) {
			var i = _g1++;
			var filed = this.head[i];
			var ft = filed.type;
			var val0 = row[i];
			var val1 = null;
			if(ft != null && ft.length > 0 && acsv_Table.JSON_TYPES.indexOf(ft) != -1) {
				if(val0 != null) {
					val1 = JSON.parse(val0);
				}
			} else {
				val1 = val0;
			}
			obj.push(val1);
		}
		return obj;
	}
	,fmtObj: function(row) {
		var obj = { };
		var _g1 = 0;
		var _g = this.head.length;
		while(_g1 < _g) {
			var i = _g1++;
			var field = this.head[i];
			var name = field.name;
			var ft = field.type;
			var val0 = row[i];
			var val1 = null;
			if(ft != null && ft.length > 0 && acsv_Table.JSON_TYPES.indexOf(ft) != -1) {
				if(val0 != null) {
					val1 = JSON.parse(val0);
				}
			} else {
				val1 = val0;
			}
			obj[name] = val1;
		}
		return obj;
	}
	,toFirstRow: function() {
		var rzl = null;
		if(this._selector != null && this._selector.length > 0) {
			rzl = this.fmtRow(this._selector[0]);
		}
		this._selector = null;
		return rzl;
	}
	,toLastRow: function() {
		var rzl = null;
		if(this._selector != null) {
			var l = this._selector.length;
			if(l > 0) {
				rzl = this.fmtRow(this._selector[l - 1]);
			}
		}
		this._selector = null;
		return rzl;
	}
	,toRows: function() {
		if(this._selector == null) {
			return null;
		}
		var dst = [];
		var _g1 = 0;
		var _g = this._selector.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = this._selector[i];
			dst.push(this.fmtRow(row));
		}
		this._selector = null;
		return dst;
	}
	,toFirstObj: function() {
		var rzl = null;
		if(this._selector != null && this._selector.length > 0) {
			rzl = this.fmtObj(this._selector[0]);
		}
		this._selector = null;
		return rzl;
	}
	,toLastObj: function() {
		var rzl = null;
		if(this._selector != null) {
			var l = this._selector.length;
			if(l > 0) {
				rzl = this.fmtObj(this._selector[l - 1]);
			}
		}
		this._selector = null;
		return rzl;
	}
	,toObjs: function() {
		if(this._selector == null) {
			return null;
		}
		var dst = [];
		var _g1 = 0;
		var _g = this._selector.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = this._selector[i];
			dst.push(this.fmtObj(row));
		}
		this._selector = null;
		return dst;
	}
	,toTable: function() {
		if(this._selector == null) {
			return null;
		}
		var t = new acsv_Table();
		t.head = this.head.concat([]);
		t.body = this._selector;
		this._selector = null;
		return t;
	}
	,selectAll: function() {
		this._selector = this.body;
		return this;
	}
	,selectFirstRow: function() {
		this._selector = [this.body[0]];
		return this;
	}
	,selectLastRow: function() {
		this._selector = [this.body[this.body.length - 1]];
		return this;
	}
	,selectAt: function(rowIndices) {
		var dst = [];
		var maxLen = this.body.length;
		var _g1 = 0;
		var _g = rowIndices.length;
		while(_g1 < _g) {
			var i = _g1++;
			var rowIndex = rowIndices[i];
			if(rowIndex >= 0 && rowIndex < maxLen) {
				dst.push(this.body[rowIndex]);
			}
		}
		this._selector = dst;
		return this;
	}
	,selectWhenIn: function(limit,values,colIndex) {
		if(colIndex == null) {
			colIndex = 0;
		}
		var dst = [];
		var _g1 = 0;
		var _g = values.length;
		while(_g1 < _g) {
			var i = _g1++;
			var value = values[i];
			this.selectWhenE(limit,value,colIndex,dst);
			this._selector = null;
		}
		this._selector = dst;
		return this;
	}
	,selectWhenE: function(limit,value,colIndex,extraSelector) {
		if(colIndex == null) {
			colIndex = 0;
		}
		var dst = extraSelector;
		if(dst == null) {
			dst = [];
		}
		if(limit == 1) {
			var m = this._indexSet[colIndex];
			if(m != null) {
				var val = m[value];
				if(val != null) {
					dst.push(val);
				}
				this._selector = dst;
				return this;
			}
		}
		var src = this._selector;
		if(src == null) {
			src = this.body;
		}
		var _g1 = 0;
		var _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = src[i];
			if(row[colIndex] == value) {
				dst.push(row);
				--limit;
				if(limit == 0) {
					break;
				}
			}
		}
		this._selector = dst;
		return this;
	}
	,selectWhenE2: function(limit,value1,value2,colIndex2,colIndex1) {
		if(colIndex1 == null) {
			colIndex1 = 0;
		}
		if(colIndex2 == null) {
			colIndex2 = 1;
		}
		var src = this._selector;
		if(src == null) {
			src = this.body;
		}
		var dst = [];
		var _g1 = 0;
		var _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = src[i];
			if(row[colIndex1] == value1 && row[colIndex2] == value2) {
				dst.push(row);
				--limit;
				if(limit == 0) {
					break;
				}
			}
		}
		this._selector = dst;
		return this;
	}
	,selectWhenE3: function(limit,value1,value2,value3,colIndex3,colIndex2,colIndex1) {
		if(colIndex1 == null) {
			colIndex1 = 0;
		}
		if(colIndex2 == null) {
			colIndex2 = 1;
		}
		if(colIndex3 == null) {
			colIndex3 = 2;
		}
		var src = this._selector;
		if(src == null) {
			src = this.body;
		}
		var dst = [];
		var _g1 = 0;
		var _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = src[i];
			if(row[colIndex1] == value1 && row[colIndex2] == value2 && row[colIndex3] == value3) {
				dst.push(row);
				--limit;
				if(limit == 0) {
					break;
				}
			}
		}
		this._selector = dst;
		return this;
	}
	,selectWhenG: function(limit,withEqu,value,colIndex) {
		if(colIndex == null) {
			colIndex = 0;
		}
		var src = this._selector;
		if(src == null) {
			src = this.body;
		}
		var dst = [];
		var _g1 = 0;
		var _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = src[i];
			var rowVal = row[colIndex];
			if(rowVal > value || withEqu && rowVal == value) {
				dst.push(row);
				--limit;
				if(limit == 0) {
					break;
				}
			}
		}
		this._selector = dst;
		return this;
	}
	,selectWhenL: function(limit,withEqu,value,colIndex) {
		if(colIndex == null) {
			colIndex = 0;
		}
		var src = this._selector;
		if(src == null) {
			src = this.body;
		}
		var dst = [];
		var _g1 = 0;
		var _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = src[i];
			var rowVal = row[colIndex];
			if(rowVal < value || withEqu && rowVal == value) {
				dst.push(row);
				--limit;
				if(limit == 0) {
					break;
				}
			}
		}
		this._selector = dst;
		return this;
	}
	,selectWhenGreaterAndLess: function(limit,GWithEqu,LWithEqu,GValue,LValue,colIndex) {
		if(colIndex == null) {
			colIndex = 0;
		}
		var src = this._selector;
		if(src == null) {
			src = this.body;
		}
		var dst = [];
		var _g1 = 0;
		var _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = src[i];
			var rowVal = row[colIndex];
			var v1 = rowVal > GValue || GWithEqu && rowVal == GValue;
			var v2 = rowVal < LValue || LWithEqu && rowVal == LValue;
			if(v1 && v2) {
				dst.push(row);
				--limit;
				if(limit == 0) {
					break;
				}
			}
		}
		this._selector = dst;
		return this;
	}
	,selectWhenLessOrGreater: function(limit,LWithEqu,GWithEqu,LValue,GValue,colIndex) {
		if(colIndex == null) {
			colIndex = 0;
		}
		var src = this._selector;
		if(src == null) {
			src = this.body;
		}
		var dst = [];
		var _g1 = 0;
		var _g = src.length;
		while(_g1 < _g) {
			var i = _g1++;
			var row = src[i];
			var rowVal = row[colIndex];
			var v1 = rowVal < LValue || LWithEqu && rowVal == LValue;
			var v2 = rowVal > GValue || GWithEqu && rowVal == GValue;
			if(v1 || v2) {
				dst.push(row);
				--limit;
				if(limit == 0) {
					break;
				}
			}
		}
		this._selector = dst;
		return this;
	}
};
Demo.standard_format_text = "id,id2,id3,name,brief\r\n1,20,100,John,He is a googd man\r\n2,20,100,张三,\"他是一个好人\r\n我们都喜欢他\"\r\n3,21,100,море,\"Он хороший человек\r\nмы все любим его\r\nЕго девиз:\r\n\"\"доверяй себе\"\"\"\r\n4,21,200,الشمس,صباح الخير\r\n5,22,200,चंद्रमा,सुसंध्या\r\n6,22,200,ดาว,";
Demo.enhanced_format_text = "id:int,id2:int,id3:int,name:string,weight:number,marry:bool,education:json,tags:strings,brief\r\n1,21,100,John,120.1,true,\"[\"\"AB\"\"]\",\"good,cool\",\"Today is good day\r\nTomorrow is good day too\"\r\n2,21,100,张三,121.2,false,\"[\"\"CD\"\",\"\"EF\"\"]\",good,今天是个好日子\r\n3,22,100,море,123.4,true,\"[\"\"GH\"\",\"\"AB\"\",\"\"CD\"\"]\",good,\"Сегодня хороший день\r\n\"\"Завтра тоже хороший день\"\"\"\r\n4,22,200,الشمس,124.5,false,\"{\"\"AA\"\":12}\",strong,صباح الخير\r\n5,23,200,चंद्रमा,126.7,1,\"{\"\"BB\"\":12}\",strong,सुसंध्या\r\n6,23,200,Emilia,,0,\"{\"\"CC\"\":67,\"\"DD\"\":56}\",\"strong,cool\",Hoje é um bom dia\r\n7,24,300,Ayşe,128.9,0,\"{\"\"EE\"\":68,\"\"FF\"\":56}\",\"strong,cool\",Bugün güzel bir gün\r\n8,24,300,陽菜乃,129.01,,\"{\"\"AC\"\":78,\"\"BD\"\":[90,12]}\",\"height,strong\",今日はいい日です\r\n9,25,300,Dwi,130.12,1,\"{\"\"EF\"\":78,\"\"CF\"\":[90,12]}\",,\"Hari ini adalah hari yang baik\r\nBesok juga hari yang baik\"\r\n10,25,400,Bảo,131.23,1,\"[\"\"BC\"\",{\"\"AT\"\":34}]\",\"thin,good\",\r\n11,26,400,민준,132.34,0,\"[\"\"FG\"\",{\"\"AG\"\":34}]\",\"hot,thin,good\",오늘은 좋은 날이다\r\n12,26,400,ดาว,133.456,0,,,";
acsv_Table.JSON_TYPES = ["json","strings"];
Demo.main();
})(typeof exports != "undefined" ? exports : typeof window != "undefined" ? window : typeof self != "undefined" ? self : this);
