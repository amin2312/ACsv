package acsv;

/**
 * 1. Copyright (c) 2022 amin2312
 * 2. Version 1.0.0
 * 3. MIT License
 *
 * ACsv is a easy, fast and powerful csv parse library.
 */
@:expose
class Table
{
    /**
     * Supported json field types.
     */
    private static var JSON_TYPES:Array<String> = ["json", "strings"];
    /**
     * The raw content.
     */
    public var content:String = null;
    /**
     * Parsed csv table Head.
     */
    public var head = new Array<Field>();
    /**
     * Parsed csv table Body.
     */
    public var body = new Array<Array<Dynamic>>();
    /**
     * Index Set(optimize for read).
     */
    private var _indexSet:Dynamic = {};
    /**
     * Selected data(for Method Chaining).
     */
    private var _selector:Array<Array<Dynamic>> = null;
    /**
     * Constructor.
     */
    @:dox(hide)
    public function new()
    {}
    /**
     * Merge a table.
     * <br/><b>Notice:</b> two tables' structure must be same.
     * @param b source table
     * @return THIS instance
     */
    public function merge(b:Table):Table
    {
        this.body = this.body.concat(b.body);
        var index = b.content.indexOf('\r\n');
        if (index == -1)
        {
            index = b.content.indexOf('\n');
        }
        var c = b.content.substring(index);
        this.content += c;
        return this;
    }
    /**
     * Create index for the specified column.
     * <br>This function is only valid for "selectWhenE" and "limit" param is 1.
     * <br>It will improve performance.
     * @param colIndex column index
     */
    public function createIndexAt(colIndex:Int):Void
    {
        var m:Dynamic = {};
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var key:Dynamic = row[colIndex];
            #if (js || lua)
            m[key] = row;
            #else
            Reflect.setProperty(m, key + '', row);
            #end
        }
        #if (js || lua)
        _indexSet[colIndex] = m;
        #else
        Reflect.setProperty(_indexSet, colIndex + '', m);
        #end
    }
    /**
     * Get column index by specified field name.
     * @param name As name mean
     * @return column index
     */
    public function getColIndexBy(name:String):Int
    {
        for (i in 0...this.head.length)
        {
            var field = this.head[i];
            if (field.name == name)
            {
                return i;
            }
        }
        return -1;
    }
    /**
     * Fetch a row object when the column's value is equal to the id value
     * @param values the specified value
     * @param colIndex specified column index
     * @return selected row object
     */
    public function id(value:Dynamic, colIndex:Int = 0):Dynamic
    {
        return this.selectWhenE(1, value, colIndex).toFirstObj();
    }
    /**
     * Sort by selected rows.
     * @param colIndex the column index specified for sorting
     * @param sortType 0: asc, 1: desc
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function sortBy(colIndex:Int, sortType:Int):Table
    {
        var l = _selector.length;
        for (i in 0...l)
        {
            for (j in 0...l - 1)
            {
                var ok = false;
                var a = _selector[j][colIndex];
                var b = _selector[j + 1][colIndex];
                if (sortType == 0 && a > b)
                {
                    ok = true;
                }
                else if (sortType == 1 && a < b)
                {
                    ok = true;
                }
                if (ok)
                {
                    var temp = _selector[j];
                    _selector[j] = _selector[j + 1];
                    _selector[j + 1] = temp;
                }
            }
        }
        return this;
    }
    /**
     * Get current selector(it includes all selected results).
     * <br><b>Notice:</b> It be assigned after call "select..." function
     * @return current selector
     */
    public function getCurrentSelector():Array<Dynamic>
    {
        return _selector;
    }
    /**
     * Format data to row.
     */
    private function fmtRow(row:Array<Dynamic>):Array<Dynamic>
    {
        var obj:Array<Dynamic> = [];
        for (i in 0...this.head.length)
        {
            var filed = this.head[i];
            var ft = filed.type; // avoid "type" keyword in other languages
            var val0 = row[i];
            var val1:Dynamic = null;
            if (ft != null && ft != '' && Table.JSON_TYPES.indexOf(ft) != -1)
            {
                if (val0 != null)
                {
                    val1 = haxe.Json.parse(val0);
                }
            }
            else
            {
                val1 = val0;
            }
            obj.push(val1);
        }
        return obj;
    }
    /**
     * Format data to obj.
     */
    private function fmtObj(row:Array<Dynamic>):Dynamic
    {
        var obj:Dynamic = {};
        for (i in 0...this.head.length)
        {
            var field = this.head[i];
            var name = field.name;
            var ft = field.type; // avoid "type" keyword in other languages
            var val0 = row[i];
            var val1:Dynamic = null;
            if (ft != null && ft != '' && Table.JSON_TYPES.indexOf(ft) != -1)
            {
                if (val0 != null)
                {
                    val1 = haxe.Json.parse(val0);
                }
            }
            else
            {
                val1 = val0;
            }
            #if (js || lua)
            untyped obj[name] = val1;
            #else
            Reflect.setProperty(obj, name, val1);
            #end
        }
        return obj;
    }
    /**
     * Fetch first selected result to a row and return it.
     * @return first selected row data or null
     */
    public function toFirstRow():Array<Dynamic>
    {
        var rzl = null;
        if (_selector != null && _selector.length > 0)
        {
            rzl = this.fmtRow(_selector[0]);
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch last selected result to a row and return it.
     * @return last selected row data or null
     */
    public function toLastRow():Array<Dynamic>
    {
        var rzl = null;
        if (_selector != null)
        {
            var l = _selector.length;
            if (l > 0)
            {
                rzl = this.fmtRow(_selector[l - 1]);
            }
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch all selected results to the rows and return it.
     * @return a array of row data (even if the result is empty)
     */
    public function toRows():Array<Array<Dynamic>>
    {
        if (_selector == null)
        {
            return null;
        }
        var dst = new Array<Array<Dynamic>>();
        for (i in 0..._selector.length)
        {
            var row:Array<Dynamic> = _selector[i];
            dst.push(this.fmtRow(row));
        }
        _selector = null;
        return dst;
    }
    /**
     * Fetch first selected result to a object and return it.
     * @return first selected row object or null
     */
    public function toFirstObj():Dynamic
    {
        var rzl = null;
        if (_selector != null && _selector.length > 0)
        {
            rzl = this.fmtObj(_selector[0]);
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch last selected result to a object and return it.
     * @return last selected row object or null
     */
    public function toLastObj():Dynamic
    {
        var rzl = null;
        if (_selector != null)
        {
            var l = _selector.length;
            if (l > 0)
            {
                rzl = this.fmtObj(_selector[l - 1]);
            }
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch all selected results to the objects and return it.
     * @return a array of row object (even if the result is empty)
     */
    public function toObjs():Array<Dynamic>
    {
        if (_selector == null)
        {
            return null;
        }
        var dst = new Array<Dynamic>();
        for (i in 0..._selector.length)
        {
            var row:Array<Dynamic> = _selector[i];
            dst.push(this.fmtObj(row));
        }
        _selector = null;
        return dst;
    }
    /**
     * Fetch all selected results to a new table.
     * @return a new table instance
     */
    public function toTable():Table
    {
        if (_selector == null)
        {
            return null;
        }
        var t = new Table();
        t.head = this.head.concat([]);
        t.body = this._selector;
        _selector = null;
        return t;
    }
    /**
     * Select all rows.
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectAll():Table
    {
        _selector = body;
        return this;
    }
    /**
     * Select the first row.
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectFirstRow():Table
    {
        _selector = [body[0]];
        return this;
    }
    /**
     * Select the last row.
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectLastRow():Table
    {
        _selector = [body[body.length - 1]];
        return this;
    }
    /**
     * Selects the specified <b>rows</b> by indices.
     * @param rowIndices specified row's indices
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectAt(rowIndices:Array<Int>):Table
    {
        var dst = new Array<Array<Dynamic>>();
        var maxLen = this.body.length;
        for (i in 0...rowIndices.length)
        {
            var rowIndex = rowIndices[i];
            if (rowIndex >= 0 && rowIndex < maxLen)
            {
                dst.push(this.body[rowIndex]);
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's value is equal to any value of array.
     * @param limit maximum length of every selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param values the array of values
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenIn(limit:Int, values:Array<Dynamic>, colIndex:Int = 0):Table
    {
        var dst = new Array<Array<Dynamic>>();
        for (i in 0...values.length)
        {
            var value = values[i];
            selectWhenE(limit, value, colIndex, dst);
            _selector = null;
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's value is equal to specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value the specified value
     * @param colIndex specified column index
     * @param extraSelector extra selector, use it to save selected result
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenE(limit:Int, value:Dynamic, colIndex:Int = 0, extraSelector:Array<Array<Dynamic>> = null):Table
    {
        var dst:Array<Array<Dynamic>> = extraSelector;
        if (dst == null)
        {
            dst = new Array<Array<Dynamic>>();
        }
        // 1.check indexed set
        if (limit == 1)
        {
            #if (js || lua)
            var m:Dynamic = _indexSet[colIndex];
            #else
            var m:Dynamic = Reflect.getProperty(_indexSet, colIndex + '');
            #end
            if (m != null)
            {
                #if (js || lua)
                var val = m[value];
                #else
                var val = Reflect.getProperty(m, value + '');
                #end
                if (val != null)
                {
                    dst.push(val);
                }
                _selector = dst;
                return this;
            }
        }
        // 2.line-by-line scan
        var src = _selector;
        if (src == null)
        {
            src = body;
        }
        for (i in 0...src.length)
        {
            var row:Array<Dynamic> = src[i];
            if (row[colIndex] == value)
            {
                dst.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's values are equal to specified values.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value1 first specified value
     * @param value2 second specified value
     * @param colIndex2 second specified column index
     * @param colIndex1 first specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenE2(limit:Int, value1:Dynamic, value2:Dynamic, colIndex2:Int = 1, colIndex1:Int = 0):Table
    {
        var src = _selector;
        if (src == null)
        {
            src = body;
        }
        var dst = new Array<Array<Dynamic>>();
        for (i in 0...src.length)
        {
            var row:Array<Dynamic> = src[i];
            if (row[colIndex1] == value1 && row[colIndex2] == value2)
            {
                dst.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's values are equal to specified values.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value1 first specified value
     * @param value2 second specified value
     * @param value3 third specified value
     * @param colIndex3 third specified column index
     * @param colIndex2 second specified column index
     * @param colIndex1 first specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenE3(limit:Int, value1:Dynamic, value2:Dynamic, value3:Dynamic, colIndex3:Int = 2, colIndex2:Int = 1, colIndex1:Int = 0):Table
    {
        var src = _selector;
        if (src == null)
        {
            src = body;
        }
        var dst = new Array<Array<Dynamic>>();
        for (i in 0...src.length)
        {
            var row:Array<Dynamic> = src[i];
            if (row[colIndex1] == value1 && row[colIndex2] == value2 && row[colIndex3] == value3)
            {
                dst.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's value is greater than specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param withEqu whether include equation
     * @param value the specified value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenG(limit:Int, withEqu:Bool, value:Float, colIndex:Int = 0):Table
    {
        var src = _selector;
        if (src == null)
        {
            src = body;
        }
        var dst = new Array<Array<Dynamic>>();
        for (i in 0...src.length)
        {
            var row:Array<Dynamic> = src[i];
            var rowVal = row[colIndex];
            if (rowVal > value || (withEqu && rowVal == value))
            {
                dst.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's value is less than specified values.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param withEqu whether include equation
     * @param value the specified value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenL(limit:Int, withEqu:Bool, value:Float, colIndex:Int = 0):Table
    {
        var src = _selector;
        if (src == null)
        {
            src = body;
        }
        var dst = new Array<Array<Dynamic>>();
        for (i in 0...src.length)
        {
            var row:Array<Dynamic> = src[i];
            var rowVal = row[colIndex];
            if (rowVal < value || (withEqu && rowVal == value))
            {
                dst.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's value is greater than specified value <b>and</b> less than specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param GWithEqu whether greater and equal
     * @param LWithEqu whether less and equal
     * @param GValue the specified greater value
     * @param LValue the specified less value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenGreaterAndLess(limit:Int, GWithEqu:Bool, LWithEqu:Bool, GValue:Float, LValue:Float, colIndex:Int = 0):Table
    {
        var src = _selector;
        if (src == null)
        {
            src = body;
        }
        var dst = new Array<Array<Dynamic>>();
        for (i in 0...src.length)
        {
            var row:Array<Dynamic> = src[i];
            var rowVal = row[colIndex];
            var v1 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
            var v2 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
            if (v1 && v2)
            {
                dst.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Select the rows when the column's value is less than specified value <b>or</b> greater than specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param LWithEqu whether less and equal
     * @param GWithEqu whether greater and equal
     * @param LValue the specified less value
     * @param GValue the specified greater value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public function selectWhenLessOrGreater(limit:Int, LWithEqu:Bool, GWithEqu:Bool, LValue:Float, GValue:Float, colIndex:Int = 0):Table
    {
        var src = _selector;
        if (src == null)
        {
            src = body;
        }
        var dst = new Array<Array<Dynamic>>();
        for (i in 0...src.length)
        {
            var row:Array<Dynamic> = src[i];
            var rowVal = row[colIndex];
            var v1 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
            var v2 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
            if (v1 || v2)
            {
                dst.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = dst;
        return this;
    }
    /**
     * Parse csv conent.
     * @param content As name mean
     * @param filedSeparator filed separator
     * @param filedMultiLineDelimiter filed multi-line delimiter
     * @return a table instance
     */
    public static function Parse(content:String, filedSeparator:String = ",", filedMultiLineDelimiter:String = "\""):Table
    {
        var table:Table = arrayToRows(textToArray(content, filedSeparator, filedMultiLineDelimiter));
        table.content = content;
        return table;
    }
    /**
     * Convert text to array.
     */
    static private function textToArray(text:String, FS:String = ",", FML:String = "\""):Array<Array<Dynamic>>
    {
        var FMLs = FML + FML;
        var arr:Array<Array<Dynamic>> = [];
        var maxLen:Int = text.length;
        var ptr:String = text;
        var ptrPos:Int = 0;
        while (true)
        {
            var curLen = maxLen - ptrPos;
            var cellIndexA:Int = 0;
            var cellIndexB:Int = 0;
            var cells:Array<Dynamic> = [];
            var cell:String = null;
            var cc:String = null; // cureent character
            while (cellIndexB < curLen)
            {
                cellIndexA = cellIndexB;
                cc = ptr.charAt(ptrPos + cellIndexB);
                if (cc == "\r" && ptr.charAt(ptrPos + cellIndexB + 1) == "\n") // line is over
                {
                    cellIndexB += 2;
                    break;
                }
                if (cc == "\n") // line is over
                {
                    cellIndexB += 1;
                    break;
                }
                if (cc == FS) // is separator
                {
                    cell = "";
                    var nextPos = ptrPos + cellIndexB + 1;
                    if (nextPos >= maxLen)
                    {
                        cc = '\n'; // fix the bug when the last cell is empty
                    }
                    else
                    {
                        cc = ptr.charAt(nextPos);
                    }
                    if (cellIndexA == 0 || cc == FS || cc == "\n") // is empty cell
                    {
                        cellIndexB += 1;
                        cells.push("");
                    }
                    else if (cc == "\r" && ptr.charAt(ptrPos + cellIndexB + 2) == "\n") // is empty cell
                    {
                        cellIndexB += 2;
                        cells.push("");
                    }
                    else
                    {
                        cellIndexB += 1;
                    }
                }
                else if (cc == FML) // is double quote
                {
                    // pass DQ
                    cellIndexB++;
                    // 1.find the nearest double quote
                    while (true)
                    {
                        cellIndexB = ptr.indexOf(FML, ptrPos + cellIndexB);
                        if (cellIndexB == -1)
                        {
                            trace("[ACsv] Invalid Double Quote");
                            return null;
                        }
                        cellIndexB -= ptrPos;
                        var nextPos = ptrPos + cellIndexB + 1;
                        if (nextPos < maxLen)
                        {
                            if (ptr.charAt(nextPos) == FML) // """" is normal double quote
                            {
                                cellIndexB += 2; // pass """"
                                continue;
                            }
                        }
                        break;
                    }
                    // 2.truncate the content of double quote
                    cell = ptr.substring(ptrPos + cellIndexA + 1, ptrPos + cellIndexB);
                    cell = StringTools.replace(cell, FMLs, FML); // convert """" to ""
                    cells.push(cell);
                    // pass DQ
                    cellIndexB++;
                }
                else // is normal
                {
                    // 1.find the nearest comma and LF
                    var indexA:Int = ptr.indexOf(FS, ptrPos + cellIndexB);
                    if (indexA == -1)
                    {
                        indexA = curLen; // is last cell
                    }
                    else
                    {
                        indexA -= ptrPos;
                    }
                    var indexB:Int = ptr.indexOf("\r\n", ptrPos + cellIndexB);
                    if (indexB == -1)
                    {
                        indexB = ptr.indexOf("\n", ptrPos + cellIndexB);
                    }
                    if (indexB == -1)
                    {
                        indexB = curLen;
                    }
                    else
                    {
                        indexB -= ptrPos;
                    }
                    cellIndexB = indexA;
                    if (indexB < indexA) // row is end
                    {
                        cellIndexB = indexB;
                    }
                    // 2.Truncate the cell contennt
                    cell = ptr.substring(ptrPos + cellIndexA, ptrPos + cellIndexB);
                    cells.push(cell);
                }
            }
            arr.push(cells);
            // move to next position
            ptrPos += cellIndexB;
            if (ptrPos >= maxLen)
            {
                break;
            }
        }
        return arr;
    }
    /**
     * Convert array to rows.
     */
    static private function arrayToRows(arr:Array<Array<Dynamic>>):Table
    {
        var rawHead:Array<Dynamic> = arr.shift();
        var srcBody:Array<Array<Dynamic>> = arr;
        // parse head
        var newHead:Array<Field> = new Array<Field>();
        for (i in 0...rawHead.length)
        {
            var fullName:String = rawHead[i];
            var parts:Array<String> = fullName.split(":");
            var filed = new Field();
            filed.fullName = fullName;
            filed.name = parts[0];
            filed.type = parts[1];
            newHead.push(filed);
        }
        // parse body
        for (i in 0...srcBody.length)
        {
            var row:Array<Dynamic> = srcBody[i];
            for (j in 0...row.length)
            {
                var cell:String = row[j];
                var newVal:Dynamic = cell;
                var isEmptyCell = (cell == null || cell == '');
                var ft:String = newHead[j].type; // avoid "type" keyword in other languages
                if (ft == "bool")
                {
                    if (isEmptyCell || cell == "false" || cell == '0')
                    {
                        newVal = false;
                    }
                    else
                    {
                        newVal = true;
                    }
                }
                else if (ft == "int")
                {
                    if (isEmptyCell)
                    {
                        newVal = 0;
                    }
                    else
                    {
                        #if js
                        newVal = untyped parseInt(cell);
                        #else
                        newVal = Std.parseInt(cell);
                        #end
                    }
                }
                else if (ft == "number")
                {
                    if (isEmptyCell)
                    {
                        newVal = 0.0;
                    }
                    else
                    {
                        newVal = Std.parseFloat(cell);
                    }
                }
                else if (ft == "json")
                {
                    if (isEmptyCell)
                    {
                        newVal = null;
                    }
                    else
                    {
                        var cc = cell.charAt(0);
                        if (!(cc == '[' || cc == '{' ))
                        {
                            trace("[ACsv] Invalid json format:" + newHead[j].name + ',' + cell);
                            return null;
                        }
                        newVal = cell;
                    }
                }
                else if (ft == "strings")
                {
                    if (isEmptyCell)
                    {
                        newVal = "[]";
                    }
                    else
                    {
                        newVal = '["' + cell.split(',').join('\",\"') + '"]';
                    }
                }
                row[j] = newVal;
            }
            srcBody[i] = row; // update row
        }
        // create table
        var table:Table = new Table();
        table.head = newHead;
        table.body = srcBody;
        return table;
    }
}
