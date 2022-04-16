package acsv;

/**
 * 1. Copyright (c) 2022 amin2312
 * 2. Version 1.0.0
 * 3. MIT License
 *
 * ACsv is a easy, tiny and powerful csv parse library,
 * It also provides cross-platform versions(via haxe).
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
    public var content:String;
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
	 **/
    private var _selectd:Array<Dynamic>;
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
	 */
    public function merge(b:Table):Void
    {
        this.body = this.body.concat(b.body);
        var index = b.content.indexOf('\r\n');
        if (index == -1)
        {
            index = b.content.indexOf('\n');
        }
        var c = b.content.substring(index);
        this.content += c;
    }
    /**
	 * Create index for the specified column.
	 * <br>This function is only valid for "selectWhenE" and "limit" param is 1.
	 * <br>It will improve performance.
	 * @param colIndex column index
	 */
    public function createIndexAt(colIndex:Int):Void
    {
        var map:Dynamic = {};
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var key:Dynamic = row[colIndex];
            #if (js || lua)
            map[key] = row;
            #else
            Reflect.setProperty(map, key + '', row);
            #end
        }
        #if (js || lua)
        _indexSet[colIndex] = map;
        #else
        Reflect.setProperty(_indexSet, colIndex + '', map);
        #end
    }
    /**
	 * Get column index by specified field name.
	 * @param name As name mean.
	 */
    public function getColumnIndexBy(name:String):Int
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
	 * Get current selected data.
	 <br>It be assigned after call "select???" function
	 */
    public function getCurrentSelectdData():Array<Dynamic>
    {
        return _selectd;
    }
    /**
	 * Format data to row.
	 */
    private function fmtRow(row:Array<Dynamic>):Array<Dynamic>
    {
        var obj:Array<Dynamic> = [];
        for (i in 0...this.head.length)
        {
            var type = this.head[i].type;
            var val0 = row[i];
            var val1:Dynamic = null;
            if (type != null && type != '' && Table.JSON_TYPES.indexOf(type) != -1)
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
            var name = this.head[i].name;
            var type = this.head[i].type;
            var val0 = row[i];
            var val1:Dynamic = null;
            if (type != null && type != '' && Table.JSON_TYPES.indexOf(type) != -1)
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
	 */
    public function toFirstRow():Array<Dynamic>
    {
        if (_selectd == null || _selectd.length == 0)
        {
            return null;
        }
        return this.fmtRow(_selectd[0]);
    }
    /**
	 * Fetch last selected result to a row and return it.
	 */
    public function toLastRow():Array<Dynamic>
    {
        if (_selectd == null || _selectd.length == 0)
        {
            return null;
        }
        return this.fmtRow(_selectd[_selectd.length - 1]);
    }
    /**
	 * Fetch all selected results to the rows and return it.
	 */
    public function toRows():Array<Array<Dynamic>>
    {
        if (_selectd == null)
        {
            return null;
        }
        var arr = new Array<Array<Dynamic>>();
        for (i in 0..._selectd.length)
        {
            var row:Array<Dynamic> = _selectd[i];
            arr.push(this.fmtRow(row));
        }
        return arr;
    }
    /**
	 * Fetch first selected result to a object and return it.
	 */
    public function toFirstObj():Dynamic
    {
        if (_selectd == null || _selectd.length == 0)
        {
            return null;
        }
        return this.fmtObj(_selectd[0]);
    }
    /**
	 * Fetch last selected result to a object and return it.
	 */
    public function toLastObj():Dynamic
    {
        if (_selectd == null || _selectd.length == 0)
        {
            return null;
        }
        return this.fmtObj(_selectd[_selectd.length - 1]);
    }
    /**
	 * Fetch all selected results to the objects and return it.
	 */
    public function toObjs():Array<Dynamic>
    {
        if (_selectd == null)
        {
            return null;
        }
        var arr = new Array<Dynamic>();
        for (i in 0..._selectd.length)
        {
            var row:Array<Dynamic> = _selectd[i];
            arr.push(this.fmtObj(row));
        }
        return arr;
    }
    /**
	 * Select all rows.
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectAll():Table
    {
        _selectd = body;
        return this;
    }
    /**
	 * Select the first row.
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectFirstRow():Table
    {
        _selectd = [body[0]];
        return this;
    }
    /**
	 * Select the last row.
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectLastRow():Table
    {
        _selectd = [body[body.length - 1]];
        return this;
    }
    /**
     * Select the rows when the column's value is equal to specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value the specified value
     * @param colIndex specified column's index
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectWhenE(limit:Int, value:Dynamic, colIndex:Int = 0):Table
    {
        // 1.check indexed set
        if (limit == 1)
        {
            #if (js || lua)
            var map:Dynamic = _indexSet[colIndex];
            #else
            var map:Dynamic = Reflect.getProperty(_indexSet, colIndex + '');
            #end
            if (map != null)
            {
                #if (js || lua)
                var val = map[value];
                #else
                var val = Reflect.getProperty(map, value + '');
                #end
                if (val != null)
                {
                    _selectd = [val];
                }
                else
                {
                    _selectd = null;
                }
                return this;
            }
        }
        // 2.line-by-line scan
        var rows = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            if (row[colIndex] == value)
            {
                rows.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selectd = rows;
        return this;
    }
    /**
	 * Select the rows when the column's values are equal to specified values.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value1 first specified value
     * @param value2 second specified value
     * @param colIndex2 second specified column's index
     * @param colIndex1 first specified column's index
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectWhenE2(limit:Int, value1:Dynamic, value2:Dynamic, colIndex2:Int = 1, colIndex1:Int = 0):Table
    {
        var rows:Array<Dynamic> = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            if (row[colIndex1] == value1 && row[colIndex2] == value2)
            {
                rows.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selectd = rows;
        return this;
    }
    /**
	 * Select the rows when the column's values are equal to specified values.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value1 first specified value
     * @param value2 second specified value
     * @param value3 third specified value
     * @param colIndex3 third specified column's index
     * @param colIndex2 second specified column's index
     * @param colIndex1 first specified column's index
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectWhenE3(limit:Int, value1:Dynamic, value2:Dynamic, value3:Dynamic, colIndex3:Int = 2, colIndex2:Int = 1, colIndex1:Int = 0):Table
    {
        var rows:Array<Dynamic> = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            if (row[colIndex1] == value1 && row[colIndex2] == value2 && row[colIndex3] == value3)
            {
                rows.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selectd = rows;
        return this;
    }
    /**
	 * Select the rows when the column's value is greater than specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param withEqu whether include equation
     * @param value the specified value
     * @param colIndex specified column's index
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectWhenG(limit:Int, withEqu:Bool, value:Float, colIndex:Int = 0):Table
    {
        var rows = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var rowVal = row[colIndex];
            if (rowVal > value || (withEqu && rowVal == value))
            {
                rows.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selectd = rows;
        return this;
    }
    /**
	 * Select the rows when the column's value is less than specified values.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param withEqu whether include equation
     * @param value the specified value
     * @param colIndex specified column's index
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectWhenL(limit:Int, withEqu:Bool, value:Float, colIndex:Int = 0):Table
    {
        var rows = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var rowVal = row[colIndex];
            if (rowVal < value || (withEqu && rowVal == value))
            {
                rows.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selectd = rows;
        return this;
    }
    /**
	 * Select the rows when the column's value is greater than specified value <b>and</b> less than specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param GWithEqu whether greater and equal
     * @param LWithEqu whether less and equal
     * @param GValue the specified greater value
     * @param LValue the specified less value
     * @param colIndex specified column's index
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectWhenGreaterAndLess(limit:Int, GWithEqu:Bool, LWithEqu:Bool, GValue:Float, LValue:Float, colIndex:Int = 0):Table
    {
        var rows = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var rowVal = row[colIndex];
            var v1 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
            var v2 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
            if (v1 && v2)
            {
                rows.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selectd = rows;
        return this;
    }
    /**
	 * Select the rows when the column's value is less than specified value <b>or</b> greater than specified value.
     * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param LWithEqu whether less and equal
     * @param GWithEqu whether greater and equal
     * @param LValue the specified less value
     * @param GValue the specified greater value
     * @param colIndex specified column's index
     * @return Current THIS instance(Method Chaining), can call "to???" function to get result in next step.
	 */
    public function selectWhenLessOrGreater(limit:Int, LWithEqu:Bool, GWithEqu:Bool, LValue:Float, GValue:Int, colIndex:Int = 0):Table
    {
        var rows = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var rowVal = row[colIndex];
            var v1 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
            var v2 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
            if (v1 || v2)
            {
                rows.push(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selectd = rows;
        return this;
    }
    /**
	 * Parse csv conent.
	 */
    public static function Parse(content:String):Table
    {
        var table:Table = arrayToRows(textToArray(content));
        table.content = content;
        return table;
    }
    /**
	 * Convert text to array.
	 */
    static private function textToArray(text:String):Array<Array<Dynamic>>
    {
        var array:Array<Array<Dynamic>> = [];
        var maxLen:Int = text.length;
        var ptr:String = text;
        var ptrPos:Int = 0;
        while (true)
        {
            var curLen = maxLen - ptrPos;
            var cellIndexA:Int = 0;
            var cellIndexB:Int = 0;
            var cells:Array<Dynamic> = [];
            var cell:String;
            var chr:String;
            while (cellIndexB < curLen)
            {
                cellIndexA = cellIndexB;
                chr = ptr.charAt(ptrPos + cellIndexB);
                if (chr == "\n" || chr == "\r\n") // line is over
                {
                    cellIndexB += 1;
                    break;
                }
                if (chr == "\r" && ptr.charAt(ptrPos + cellIndexB + 1) == "\n") // line is over
                {
                    cellIndexB += 2;
                    break;
                }
                if (chr == ",") // is separator
                {
                    cell = "";
                    var nextPos = ptrPos + cellIndexB + 1;
                    if (nextPos >= maxLen)
                    {
                        chr = '\n'; // fix the bug when the last cell is empty
                    }
                    else
                    {
                        chr = ptr.charAt(nextPos);
                    }
                    if (cellIndexA == 0 || chr == "," || chr == "\n" || chr == "\r\n") // is empty cell
                    {
                        cellIndexB += 1;
                        cells.push("");
                    }
                    else if (chr == "\r" && ptr.charAt(ptrPos + cellIndexB + 2) == "\n") // is empty cell
                    {
                        cellIndexB += 2;
                        cells.push("");
                    }
                    else
                    {
                        cellIndexB += 1;
                    }
                }
                else if (chr == "\"") // is double quote
                {
                    // pass DQ
                    cellIndexB++;
                    // 1.find the nearest double quote
                    while (true)
                    {
                        cellIndexB = ptr.indexOf("\"", ptrPos + cellIndexB);
                        if (cellIndexB == -1)
                        {
                            trace("[ACsv] Invalid Double Quote");
                            return null;
                        }
                        cellIndexB -= ptrPos;
                        if (ptr.charAt(ptrPos + cellIndexB + 1) == "\"") // """" is normal double quote
                        {
                            cellIndexB += 2; // pass """"
                            continue;
                        }
                        break;
                    }
                    // 2.truncate the content of double quote
                    cell = ptr.substring(ptrPos + cellIndexA + 1, ptrPos + cellIndexB);
                    cell = StringTools.replace(cell, "\"\"", "\""); // convert """" to ""
                    cells.push(cell);
                    // pass DQ
                    cellIndexB++;
                }
                else // is normal
                {
                    // 1.find the nearest comma and LF
                    var indexA:Int = ptr.indexOf(",", ptrPos + cellIndexB);
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
                        if (indexB == -1)
                        {
                            indexB = curLen;
                        }
                        else
                        {
                            indexB -= ptrPos;
                        }
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
            array.push(cells);
            // move to next position
            ptrPos += cellIndexB;
            if (ptrPos >= maxLen)
            {
                break;
            }
        }
        return array;
    }
    /**
	 * Convert array to rows.
	 */
    static private function arrayToRows(array:Array<Array<Dynamic>>):Table
    {
        var head:Array<Dynamic> = array.shift();
        var body:Array<Array<Dynamic>> = array;
        // parse head
        var fileds:Array<Field> = new Array<Field>();
        for (i in 0...head.length)
        {
            var fullName:String = head[i];
            var parts:Array<String> = fullName.split(":");
            var filed = new Field();
            filed.fullName = fullName;
            filed.name = parts[0];
            filed.type = parts[1];
            fileds.push(filed);
        }
        // parse body
        for (i in 0...body.length)
        {
            var row:Array<Dynamic> = body[i];
            for (j in 0...row.length)
            {
                var type:String = fileds[j].type;
                var cell:String = row[j];
                var newVal:Dynamic = cell;
                var isEmptyCell = (cell == null || cell == '');
                if (type == "bool")
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
                else if (type == "int")
                {
                    if (isEmptyCell)
                    {
                        newVal = 0;
                    }
                    else
                    {
                        #if js
                        newVal = untyped parseInt(newVal);
                        #else
                        newVal = Std.parseInt(newVal);
                        #end
                    }
                }
                else if (type == "number")
                {
                    if (isEmptyCell)
                    {
                        newVal = 0.0;
                    }
                    else
                    {
                        newVal = Std.parseFloat(newVal);
                    }
                }
                else if (type == "json")
                {
                    if (isEmptyCell)
                    {
                        newVal = null;
                    }
                    else
                    {
                        var chr0 = cell.charAt(0);
                        if (!(chr0 == '[' || chr0 == '{' ))
                        {
                            trace("[ACsv] Invalid json format:" + fileds[j].name + ',' + cell);
                            return null;
                        }
                        newVal = cell;
                    }
                }
                else if (type == "strings")
                {
                    if (isEmptyCell)
                    {
                        newVal = "[]";
                    }
                    else
                    {
                        newVal = '["' + cell.split(',').join('","') + '"]';
                    }
                }
                row[j] = newVal;
            }
            body[i] = row; // update row
        }
        // create table
        var table:Table = new Table();
        table.head = fileds;
        table.body = body;
        return table;
    }
}
