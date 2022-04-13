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
	 * Head.
	 */
    public var head = new Array<Field>();
    /**
	 * Body.
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
    public function new()
    {}
    /**
	 * Merge table.
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
	 * Creates index at the specified column index.
     * This function is only valid for "selectWhenE" and "limit" param is 1.
	 * @param colIndex column index
	 */
    public function createIndexAt(colIndex:Int):Void
    {
        var map:Dynamic = {};
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var key:Dynamic = row[colIndex];
            map[key] = row;
        }
        _indexSet[colIndex] = map;
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
            var val1:Dynamic;
            if (type != null && type != '' && Table.JSON_TYPES.indexOf(type) != -1)
            {
                val1 = haxe.Json.parse(val0);
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
            var val1:Dynamic;
            if (type != null && type != '' && Table.JSON_TYPES.indexOf(type) != -1)
            {
                val1 = haxe.Json.parse(val0);
            }
            else
            {
                val1 = val0;
            }
            untyped obj[name] = val1;
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
	 * Fetch all selected result to the rows and return it.
	 */
    public function toRows():Array<Array<Dynamic>>
    {
        if (_selectd == null || _selectd.length == 0)
        {
            return null;
        }
        var objs = new Array<Array<Dynamic>>();
        for (i in 0..._selectd.length)
        {
            var row:Array<Dynamic> = _selectd[i];
            objs.push(this.fmtRow(row));
        }
        return objs;
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
	 * Fetch all selected result to the objects and return it.
	 */
    public function toObjs():Array<Dynamic>
    {
        if (_selectd == null || _selectd.length == 0)
        {
            return null;
        }
        var objs = new Array<Dynamic>();
        for (i in 0..._selectd.length)
        {
            var row:Array<Dynamic> = _selectd[i];
            objs.push(this.fmtObj(row));
        }
        return objs;
    }
    /**
	 * Select all rows.
	 */
    public function selectAll():Table
    {
        _selectd = body;
        return this;
    }
    /**
	 * Select the first row.
	 */
    public function selectFirstRow():Table
    {
        _selectd = [body[0]];
        return this;
    }
    /**
	 * Select the last row.
	 */
    public function selectLastRow():Table
    {
        _selectd = [body[body.length - 1]];
        return this;
    }
    /**
	 * Select the rows when the column's value is equal to specified value.
     * @param limit maximum length of selected result(0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
	 * @param value the specified value
	 * @param colIndex specified column's index
	 */
    public function selectWhenE(limit:Int, value:Dynamic, colIndex:Int = 0):Table
    {
        // 1.check indexed set
        if (limit == 1)
        {
            var map:Dynamic = _indexSet[colIndex];
            if (map != null)
            {
                var val = map[value];
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
     * @param limit maximum length of selected result(0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
	 * @param value1 first specified value
	 * @param value2 second specified value
	 * @param colIndex2 second specified column's index
	 * @param colIndex1 first specified column's index
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
	 * @param limit maximum length of selected result(0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
	 * @param value1 first specified value
	 * @param value2 second specified value
	 * @param value3 third specified value
	 * @param colIndex3 third specified column's index
	 * @param colIndex2 second specified column's index
	 * @param colIndex1 first specified column's index
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
	 * Select the rows where the column's value is greater than specified value.
     * @param limit maximum length of selected result(0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param withEqu whether include equation
	 * @param value the specified value
	 * @param colIndex specified column's index
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
	 * Select the rows where the column's value is less than specified values.
	 * @param limit maximum length of selected result(0 is infinite, if you only need one result, 1 is recommended, it will improve performance)
     * @param withEqu whether include equation
	 * @param value the specified value
	 * @param colIndex specified column's index
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
	 * Select the rows where the column's value is greater than specified value and less than specified value.
     * @param limit maximum length of selected result(0 is infinite, if you only need one result, 1 is recommended, it will improve performance)
     * @param GwithEqu is greater than and equal to
     * @param LwithEqu is less than and equal to
	 * @param value the specified value
	 * @param colIndex specified column's index
	 */
    public function selectWhenGTandLT(limit:Int, GwithEqu:Bool, LwithEqu:Bool, value:Float, colIndex:Int = 0):Table
    {
        var rows = new Array<Dynamic>();
        for (i in 0...this.body.length)
        {
            var row:Array<Dynamic> = this.body[i];
            var rowVal = row[colIndex];
            if (rowVal > value || (GwithEqu && rowVal == value))
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
	 * Parse conent.
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
                            throw "Invalid Double Quote";
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
                switch (type) {
                    case "bool":
                        if (isEmptyCell || cell == "false" || cell == '0')
                        {
                            newVal = false;
                        }
                        else
                        {
                            newVal = true;
                        }
                    case "int":
                        if (isEmptyCell)
                        {
                            newVal = 0;
                        }
                        else
                        {
                            newVal = Std.parseInt(newVal);
                        }
                    case "number":
                        if (isEmptyCell)
                        {
                            newVal = 0.0;
                        }
                        else
                        {
                            newVal = Std.parseFloat(newVal);
                        }
                    case "json":
                        if (isEmptyCell)
                        {
                            newVal = null;
                        }
                        else
                        {
                            if(!(cell.charAt(0) == '[' || cell.charAt(0) == '{' ))
                            {
                                throw fileds[j].name + ','+ cell;
                            }
                            newVal = cell;
                        }
                    case "strings":
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
