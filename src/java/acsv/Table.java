package acsv;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

/**
 * 1. Copyright (c) 2022 amin2312
 * 2. Version 1.0.0
 * 3. MIT License
 * <p>
 * ACsv is a easy, fast and powerful csv parse library.
 */
public class Table {
    /**
     * Supported json field types.
     */
    private static String[] JSON_TYPES = {"json", "strings"};
    /**
     * The raw content.
     */
    public String content;
    /**
     * Parsed csv table Head.
     */
    public Field[] head;
    /**
     * Parsed csv table Body.
     */
    public Object[][] body;
    /**
     * Index Set(optimize for read).
     */
    private HashMap<Integer, HashMap<Object, Object[]>> _indexSet = new HashMap<>();
    /**
     * Selected data(for Method Chaining).
     **/
    private Object[][] _selector;
    /**
     * Constructor.
     */
    public Table() {}
    /**
     * Merge a table.
     * <br><b>Notice:</b> two tables' structure must be same.
     *
     * @param b source table
     * @return THIS instance
     */
    public Table merge(Table b)
    {
        Object[][] both = Arrays.copyOf(this.body, this.body.length + b.body.length);
        System.arraycopy(b.body, 0, both, this.body.length, b.body.length);
        this.body = both;
        int index = b.content.indexOf("\r\n");
        if (index == -1)
        {
            index = b.content.indexOf("\n");
        }
        String c = b.content.substring(index);
        this.content += c;
        return this;
    }
    /**
     * Create index for the specified column.
     * <br> This function is only valid for "selectWhenE" and "limit" param is 1.
     * <br> It will improve performance.
     *
     * @param colIndex column index
     */
    public void createIndexAt(int colIndex)
    {
        HashMap<Object, Object[]> map = new HashMap<>();
        for (int i = 0, len = this.body.length; i < len; i++)
        {
            Object[] row = this.body[i];
            Object key = row[colIndex];
            map.put(key, row);
        }
        _indexSet.put(colIndex, map);
    }
    /**
     * Get column index by specified field name.
     *
     * @param name As name mean
     * @return column index
     */
    public int getColIndexBy(String name)
    {
        for (int i = 0, len = this.head.length; i < len; i++)
        {
            Field field = this.head[i];
            if (field.name == name)
            {
                return i;
            }
        }
        return -1;
    }
    /**
     * Fetch a row object when the column's value is equal to the id value
     *
     * @param values   the specified value
     * @param colIndex specified column index
     * @return selected row object
     */
    public HashMap<String, Object> id(Object value, int colIndex)
    {
        return this.selectWhenE(1, value, colIndex, null).toFirstObj();
    }
    /**
     * Sort by selected rows.
     *
     * @param colIndex the column index specified for sorting
     * @param sortType 0: asc, 1: desc
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table sortBy(int colIndex, int sortType)
    {
        int len = _selector.length;
        for (int i = 0; i < len; i++)
        {
            for (int j = 0; j < len - 1; j++)
            {
                Boolean ok = false;
                double a = (Double) _selector[j][colIndex];
                double b = (Double) _selector[j + 1][colIndex];
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
                    Object[] temp = _selector[j];
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
     *
     * @return current selector
     */
    public Object[][] getCurrentSelector()
    {
        return _selector;
    }
    /**
     * Check if the type is json.
     */
    private Boolean isJsonType(String type)
    {
        for (int i = 0, len = JSON_TYPES.length; i < len; i++)
        {
            if (JSON_TYPES[i] == type)
            {
                return true;
            }
        }
        return false;
    }
    /**
     * Format data to row.
     */
    private Object[] fmtRow(Object[] row)
    {
        ArrayList<Object> obj = new ArrayList<>();
        for (int i = 0, len = this.head.length; i < len; i++)
        {
            Field filed = this.head[i];
            String type = filed.type;
            Object val0 = row[i];
            Object val1 = null;
            if (type != null && type.isEmpty() == false && isJsonType(type))
            {
                if (val0 != null)
                {
                    val1 = val0;// new JSONObject(val0);
                }
            }
            else
            {
                val1 = val0;
            }
            obj.add(val1);
        }
        return obj.toArray();
    }
    /**
     * Format data to obj.
     */
    private HashMap<String, Object> fmtObj(Object[] row)
    {
        HashMap<String, Object> obj = new HashMap<>();
        for (int i = 0, len = this.head.length; i < len; i++)
        {
            Field field = this.head[i];
            String name = field.name;
            String type = field.type;
            Object val0 = row[i];
            Object val1 = null;
            if (type != null && type.isEmpty() == false && isJsonType(type))
            {
                if (val0 != null)
                {
                    val1 = val0;// new JSONObject(val0);
                }
            }
            else
            {
                val1 = val0;
            }
            obj.put(name, val1);
        }
        return obj;
    }
    /**
     * Fetch first selected result to a row and return it.
     *
     * @return first selected row data
     */
    public Object[] toFirstRow()
    {
        Object[] rzl = null;
        if (_selector != null && _selector.length > 0)
        {
            rzl = this.fmtRow(_selector[0]);
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch last selected result to a row and return it.
     *
     * @return last selected row data
     */
    public Object[] toLastRow()
    {
        Object[] rzl = null;
        if (_selector != null)
        {
            int len = _selector.length;
            if (len > 0)
            {
                rzl = this.fmtRow(_selector[len - 1]);
            }
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch all selected results to the rows and return it.
     *
     * @return a array of row data
     */
    public Object[][] toRows()
    {
        if (_selector == null)
        {
            return null;
        }
        int len = _selector.length;
        Object[] dst = new Object[len];
        for (int i = 0; i < len; i++)
        {
            Object[] row = _selector[i];
            dst[i] = this.fmtRow(row);
        }
        _selector = null;
        return (Object[][]) dst;
    }
    /**
     * Fetch first selected result to a object and return it.
     *
     * @return first selected row object
     */
    public HashMap<String, Object> toFirstObj()
    {
        HashMap<String, Object> rzl = null;
        if (_selector != null && _selector.length > 0)
        {
            rzl = this.fmtObj(_selector[0]);
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch last selected result to a object and return it.
     *
     * @return last selected row object
     */
    public HashMap<String, Object> toLastObj()
    {
        HashMap<String, Object> rzl = null;
        if (_selector != null)
        {
            int len = _selector.length;
            if (len > 0)
            {
                rzl = this.fmtObj(_selector[len - 1]);
            }
        }
        _selector = null;
        return rzl;
    }
    /**
     * Fetch all selected results to the objects and return it.
     *
     * @return a array of row object
     */
    @SuppressWarnings("unchecked")
    public HashMap<String, Object>[] toObjs()
    {
        if (_selector == null)
        {
            return null;
        }
        int len = _selector.length;
        Object[] dst = new Object[len];
        for (int i = 0; i < len; i++)
        {
            Object[] row = _selector[i];
            dst[i] = this.fmtObj(row);
        }
        _selector = null;
        return (HashMap<String, Object>[]) dst;
    }
    /**
     * Fetch all selected results to a new table.
     *
     * @return a new table instance
     */
    public Table toTable()
    {
        if (_selector == null)
        {
            return null;
        }
        Table t = new Table();
        t.head = Arrays.copyOf(this.head, this.head.length);
        t.body = this._selector;
        _selector = null;
        return t;
    }
    /**
     * Select all rows.
     *
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectAll()
    {
        _selector = body;
        return this;
    }
    /**
     * Select the first row.
     *
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectFirstRow()
    {
        _selector = new Object[][]{body[0]};
        return this;
    }
    /**
     * Select the last row.
     *
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectLastRow()
    {
        _selector = new Object[][]{body[body.length - 1]};
        return this;
    }
    /**
     * Selects the specified <b>rows</b> by indices.
     *
     * @param rowIndices specified row's indices
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectAt(int[] rowIndices)
    {
        ArrayList<Object> dst = new ArrayList<>();
        int maxLen = this.body.length;
        for (int i = 0, len = rowIndices.length; i < len; i++)
        {
            int rowIndex = rowIndices[i];
            if (rowIndex >= 0 && rowIndex < maxLen)
            {
                dst.add(this.body[rowIndex]);
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }
    /**
     * Select the rows when the column's value is equal to any value of array.
     *
     * @param limit    maximum length of every selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param values   the array of values
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenIn(int limit, Object[] values, int colIndex)
    {
        ArrayList<Object[]> rows = new ArrayList<>();
        for (int i = 0, len = values.length; i < len; i++)
        {
            Object value = values[i];
            selectWhenE(limit, value, colIndex, rows);
            _selector = null;
        }
        _selector = (Object[][]) rows.toArray();
        return this;
    }
    /**
     * Select the rows when the column's value is equal to specified value.
     *
     * @param limit         maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value         the specified value
     * @param colIndex      specified column index
     * @param extraSelector extra selector, use it to save selected result
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenE(int limit, Object value, int colIndex, ArrayList<Object[]> extraSelector)
    {
        ArrayList<Object[]> dst = extraSelector;
        if (dst == null)
        {
            dst = new ArrayList<>();
        }
        // 1.check indexed set
        if (limit == 1)
        {
            HashMap<Object, Object[]> map = _indexSet.get(colIndex);
            if (map != null)
            {
                Object[] val = map.get(value);
                if (val != null)
                {
                    dst.add(val);
                }
                _selector = (Object[][]) dst.toArray();
                return this;
            }
        }
        // 2.line-by-line scan
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        for (int i = 0, len = src.length; i < len; i++)
        {
            Object[] row = src[i];
            if (row[colIndex] == value)
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }
    /**
     * Select the rows when the column's values are equal to specified values.
     *
     * @param limit     maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value1    first specified value
     * @param value2    second specified value
     * @param colIndex2 second specified column index
     * @param colIndex1 first specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenE2(int limit, Object value1, Object value2, int colIndex2, int colIndex1)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object> dst = new ArrayList<>();
        for (int i = 0, len = src.length; i < len; i++)
        {
            Object[] row = src[i];
            if (row[colIndex1] == value1 && row[colIndex2] == value2)
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }
    /**
     * Select the rows when the column's values are equal to specified values.
     *
     * @param limit     maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param value1    first specified value
     * @param value2    second specified value
     * @param value3    third specified value
     * @param colIndex3 third specified column index
     * @param colIndex2 second specified column index
     * @param colIndex1 first specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenE3(int limit, Object value1, Object value2, Object value3, int colIndex3, int colIndex2, int colIndex1)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object> dst = new ArrayList<>();
        for (int i = 0, len = src.length; i < len; i++)
        {
            Object[] row = src[i];
            if (row[colIndex1] == value1 && row[colIndex2] == value2 && row[colIndex3] == value3)
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }
    /**
     * Select the rows when the column's value is greater than specified value.
     *
     * @param limit    maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param withEqu  whether include equation
     * @param value    the specified value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenG(int limit, Boolean withEqu, float value, int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object> dst = new ArrayList<>();
        for (int i = 0, len = src.length; i < len; i++)
        {
            Object[] row = src[i];
            double rowVal = (Double) row[colIndex];
            if (rowVal > value || (withEqu && rowVal == value))
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }
    /**
     * Select the rows when the column's value is less than specified values.
     *
     * @param limit    maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param withEqu  whether include equation
     * @param value    the specified value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenL(int limit, Boolean withEqu, float value, int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object> dst = new ArrayList<>();
        for (int i = 0, len = src.length; i < len; i++)
        {
            Object[] row = src[i];
            double rowVal = (Double) row[colIndex];
            if (rowVal < value || (withEqu && rowVal == value))
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }

    /**
     * Select the rows when the column's value is greater than specified value <b>and</b> less than specified value.
     *
     * @param limit    maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param GWithEqu whether greater and equal
     * @param LWithEqu whether less and equal
     * @param GValue   the specified greater value
     * @param LValue   the specified less value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenGreaterAndLess(int limit, Boolean GWithEqu, Boolean LWithEqu, float GValue, float LValue, int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object> dst = new ArrayList<>();
        for (int i = 0, len = src.length; i < len; i++)
        {
            Object[] row = src[i];
            double rowVal = (Double) row[colIndex];
            Boolean v1 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
            Boolean v2 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
            if (v1 && v2)
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }
    /**
     * Select the rows when the column's value is less than specified value <b>or</b> greater than specified value.
     *
     * @param limit    maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
     * @param LWithEqu whether less and equal
     * @param GWithEqu whether greater and equal
     * @param LValue   the specified less value
     * @param GValue   the specified greater value
     * @param colIndex specified column index
     * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
     */
    public Table selectWhenLessOrGreater(int limit, Boolean LWithEqu, Boolean GWithEqu, float LValue, float GValue,
                                         int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object> dst = new ArrayList<>();
        for (int i = 0, len = src.length; i < len; i++)
        {
            Object[] row = src[i];
            double rowVal = (Double) row[colIndex];
            Boolean v1 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
            Boolean v2 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
            if (v1 || v2)
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = (Object[][]) dst.toArray();
        return this;
    }
    /**
     * Parse csv conent.
     *
     * @param content                 As name mean
     * @param filedSeparator          filed separator
     * @param filedMultiLineDelimiter filed multi-line delimiter
     * @return a table instance
     */
    public static Table Parse(String content, String filedSeparator, String filedMultiLineDelimiter)
    {
        Table table = arrayToRows(textToArray(content, filedSeparator, filedMultiLineDelimiter));
        table.content = content;
        return table;
    }
    /**
     * Parse csv conent.
     *
     * @param content As name mean
     * @return a table instance
     */
    public static Table Parse(String content)
    {
        return Parse(content, ",", "\"");
    }
    /**
     * Convert text to array.
     */
    static private ArrayList<ArrayList<String>> textToArray(String text, String FS, String FML)
    {
        String FMLs = FML + FML;
        ArrayList<ArrayList<String>> arr = new ArrayList<>();
        int maxLen = text.length();
        String ptr = text;
        int ptrPos = 0;
        while (true)
        {
            int curLen = maxLen - ptrPos;
            int cellIndexA = 0;
            int cellIndexB = 0;
            ArrayList<String> cells = new ArrayList<>();
            String cell = null;
            String chr = null;
            while (cellIndexB < curLen)
            {
                cellIndexA = cellIndexB;
                chr = String.valueOf(ptr.charAt(ptrPos + cellIndexB));
                if (chr.equals("\n")) // line is over
                {
                    cellIndexB += 1;
                    break;
                }
                if (chr.equals("\r") && ptr.charAt(ptrPos + cellIndexB + 1) == '\n') // line is over
                {
                    cellIndexB += 2;
                    break;
                }
                if (chr.equals(FS)) // is separator
                {
                    cell = "";
                    int nextPos = ptrPos + cellIndexB + 1;
                    if (nextPos >= maxLen)
                    {
                        chr = "\n"; // fix the bug when the last cell is empty
                    }
                    else
                    {
                        chr = String.valueOf(ptr.charAt(nextPos));
                    }
                    if (cellIndexA == 0 || chr.equals(FS) || chr.equals("\n")) // is empty cell
                    {
                        cellIndexB += 1;
                        cells.add("");
                    }
                    else if (chr.equals("\r") && ptr.charAt(ptrPos + cellIndexB + 2) == '\n') // is empty cell
                    {
                        cellIndexB += 2;
                        cells.add("");
                    }
                    else
                    {
                        cellIndexB += 1;
                    }
                }
                else if (chr.equals(FML)) // is double quote
                {
                    // pass DQ
                    cellIndexB++;
                    // 1.find the nearest double quote
                    while (true)
                    {
                        cellIndexB = ptr.indexOf(FML, ptrPos + cellIndexB);
                        if (cellIndexB == -1)
                        {
                            System.out.print("[ACsv] Invalid Double Quote");
                            return null;
                        }
                        cellIndexB -= ptrPos;
                        if (String.valueOf(ptr.charAt(ptrPos + cellIndexB + 1)).equals(FML)) // """" is normal double
                        // quote
                        {
                            cellIndexB += 2; // pass """"
                            continue;
                        }
                        break;
                    }
                    // 2.truncate the content of double quote
                    cell = ptr.substring(ptrPos + cellIndexA + 1, ptrPos + cellIndexB);
                    cell = cell.replaceAll(FMLs, FML); // convert """" to ""
                    cells.add(cell);
                    // pass DQ
                    cellIndexB++;
                }
                else // is normal
                {
                    // 1.find the nearest comma and LF
                    int indexA = ptr.indexOf(FS, ptrPos + cellIndexB);
                    if (indexA == -1)
                    {
                        indexA = curLen; // is last cell
                    }
                    else
                    {
                        indexA -= ptrPos;
                    }
                    int indexB = ptr.indexOf("\r\n", ptrPos + cellIndexB);
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
                    cells.add(cell);
                }
            }
            arr.add(cells);
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
    static private Table arrayToRows(ArrayList<ArrayList<String>> arr)
    {
        ArrayList<String> rawHead = arr.remove(0);
        ArrayList<ArrayList<String>> rawBody = arr;
        // parse head
        ArrayList<Field> newHead = new ArrayList<Field>();
        for (int i = 0, len = rawHead.size(); i < len; i++)
        {
            String fullName = rawHead.get(i);
            String[] parts = fullName.split(":");
            Field filed = new Field();
            filed.fullName = fullName;
            filed.name = parts[0];
            filed.type = parts.length == 2 ? parts[1] : "";
            newHead.add(filed);
        }
        // parse body
        ArrayList<ArrayList<Object>> newBody = new ArrayList<>();
        for (int i = 0, len = rawBody.size(); i < len; i++)
        {
            ArrayList<String> row = rawBody.get(i);
            ArrayList<Object> item = new ArrayList<>();
            for (int j = 0, lenJ = row.size(); j < lenJ; j++)
            {
                String cell = row.get(j);
                Object newVal = cell;
                Boolean isEmptyCell = (cell.equals(null) || cell.equals(""));
                String type = newHead.get(j).type;
                if (type.equals("bool"))
                {
                    if (isEmptyCell || cell.equals("false") || cell.equals("0"))
                    {
                        newVal = false;
                    }
                    else
                    {
                        newVal = true;
                    }
                }
                else if (type.equals("int"))
                {
                    if (isEmptyCell)
                    {
                        newVal = 0;
                    }
                    else
                    {
                        newVal = Integer.parseInt(cell);
                    }
                }
                else if (type.equals("number"))
                {
                    if (isEmptyCell)
                    {
                        newVal = 0.0;
                    }
                    else
                    {
                        newVal = Double.parseDouble(cell);
                    }
                }
                else if (type.equals("json"))
                {
                    if (isEmptyCell)
                    {
                        newVal = null;
                    }
                    else
                    {
                        char chr0 = cell.charAt(0);
                        if (!(chr0 == '[' || chr0 == '{'))
                        {
                            System.out.print("[ACsv] Invalid json format:" + newHead.get(j).name + ',' + cell);
                            return null;
                        }
                        newVal = cell;
                    }
                }
                else if (type.equals("strings"))
                {
                    if (isEmptyCell)
                    {
                        newVal = "[]";
                    }
                    else
                    {
                        newVal = "[\"" + String.join("\",\"", cell.split(",")) + "\"]";
                    }
                }
                item.add(newVal);
            }
            newBody.add(item); // update row
        }
        // create table
        Table table = new Table();
        table.head = (Field[]) newHead.toArray();
        table.body = (Object[][]) rawBody.toArray();
        return table;
    }
}
