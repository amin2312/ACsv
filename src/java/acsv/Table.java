package acsv;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

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
     */
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
        HashMap<Object, Object[]> m = new HashMap<>();
        for (int i = 0, l = this.body.length; i < l; i++)
        {
            Object[] row = this.body[i];
            Object key = row[colIndex];
            m.put(key, row);
        }
        _indexSet.put(colIndex, m);
    }
    /**
     * Get column index by specified field name.
     *
     * @param name As name mean
     * @return column index
     */
    public int getColIndexBy(String name)
    {
        for (int i = 0, l = this.head.length; i < l; i++)
        {
            Field field = this.head[i];
            if (field.name.equals(name))
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
        int l = _selector.length;
        for (int i = 0; i < l; i++)
        {
            for (int j = 0; j < l - 1; j++)
            {
                Boolean ok = false;
                double a;
                Object objA = _selector[j][colIndex];
                if (objA instanceof Integer)
                {
                    a = ((Integer)objA).doubleValue();
                }
                else
                {
                    a = (Double)objA;
                }
                double b;
                Object objB = _selector[j + 1][colIndex];
                if (objB instanceof Integer)
                {
                    b = ((Integer)objB).doubleValue();
                }
                else
                {
                    b = (Double)objB;
                }
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
     * Format data to row.
     */
    private Object[] fmtRow(Object[] row)
    {
        ArrayList<Object> obj = new ArrayList<>();
        for (int i = 0, l = this.head.length; i < l; i++)
        {
            Field filed = this.head[i];
            String ft = filed.type;
            Object val0 = row[i];
            Object val1 = null;
            if (ft != null && ft.length() > 0 && isJsonType(ft))
            {
                if (val0 != null)
                {
                    val1 = toJsonIns((String)val0);
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
        for (int i = 0, l = this.head.length; i < l; i++)
        {
            Field field = this.head[i];
            String name = field.name;
            String ft = field.type;
            Object val0 = row[i];
            Object val1 = null;
            if (ft != null && ft.length() > 0 && isJsonType(ft))
            {
                if (val0 != null)
                {
                    val1 = toJsonIns((String)val0);
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
     * @return first selected row data or null
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
     * @return last selected row data or null
     */
    public Object[] toLastRow()
    {
        Object[] rzl = null;
        if (_selector != null)
        {
            int l = _selector.length;
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
     *
     * @return a array of row data (even if the result is empty)
     */
    public Object[][] toRows()
    {
        if (_selector == null)
        {
            return null;
        }
        int l = _selector.length;
        Object[][] dst = new Object[l][];
        for (int i = 0; i < l; i++)
        {
            Object[] row = _selector[i];
            dst[i] = this.fmtRow(row);
        }
        _selector = null;
        return dst;
    }
    /**
     * Fetch first selected result to a object and return it.
     *
     * @return first selected row object or null
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
     * @return last selected row object or null
     */
    public HashMap<String, Object> toLastObj()
    {
        HashMap<String, Object> rzl = null;
        if (_selector != null)
        {
            int l = _selector.length;
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
     *
     * @return a array of row object (even if the result is empty)
     */
    @SuppressWarnings("unchecked")
    public HashMap<String, Object>[] toObjs()
    {
        if (_selector == null)
        {
            return null;
        }
        int l = _selector.length;
        HashMap<String, Object>[] dst = new HashMap[l];
        for (int i = 0; i < l; i++)
        {
            Object[] row = _selector[i];
            dst[i] = this.fmtObj(row);
        }
        _selector = null;
        return dst;
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
        ArrayList<Object[]> dst = new ArrayList<>();
        int maxLen = this.body.length;
        for (int i = 0, l = rowIndices.length; i < l; i++)
        {
            int rowIndex = rowIndices[i];
            if (rowIndex >= 0 && rowIndex < maxLen)
            {
                dst.add(this.body[rowIndex]);
            }
        }
        _selector = ArrayListToObjectArray(dst);
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
        ArrayList<Object[]> dst = new ArrayList<>();
        for (int i = 0, l = values.length; i < l; i++)
        {
            Object value = values[i];
            selectWhenE(limit, value, colIndex, dst);
            _selector = null;
        }
        _selector = ArrayListToObjectArray(dst);
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
            HashMap<Object, Object[]> m = _indexSet.get(colIndex);
            if (m != null)
            {
                Object[] val = m.get(value);
                if (val != null)
                {
                    dst.add(val);
                }
                _selector = ArrayListToObjectArray(dst);
                return this;
            }
        }
        // 2.line-by-line scan
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        for (int i = 0, l = src.length; i < l; i++)
        {
            Object[] row = src[i];
            if (value.equals(row[colIndex]))
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = ArrayListToObjectArray(dst);
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
        ArrayList<Object[]> dst = new ArrayList<>();
        for (int i = 0, l = src.length; i < l; i++)
        {
            Object[] row = src[i];
            if (value1.equals(row[colIndex1]) && value2.equals(row[colIndex2]))
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = ArrayListToObjectArray(dst);
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
        ArrayList<Object[]> dst = new ArrayList<>();
        for (int i = 0, l = src.length; i < l; i++)
        {
            Object[] row = src[i];
            if (value1.equals(row[colIndex1]) && value2.equals(row[colIndex2]) && value3.equals(row[colIndex3]))
            {
                dst.add(row);
                limit--;
                if (limit == 0)
                {
                    break;
                }
            }
        }
        _selector = ArrayListToObjectArray(dst);
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
    public Table selectWhenG(int limit, Boolean withEqu, double value, int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object[]> dst = new ArrayList<>();
        for (int i = 0, l = src.length; i < l; i++)
        {
            Object[] row = src[i];
            double rowVal;
            Object objVal = row[colIndex];
            if (objVal instanceof Integer)
            {
                rowVal = ((Integer)objVal).doubleValue();
            }
            else
            {
                rowVal = (Double)objVal;
            }
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
        _selector = ArrayListToObjectArray(dst);
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
    public Table selectWhenL(int limit, Boolean withEqu, double value, int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object[]> dst = new ArrayList<>();
        for (int i = 0, l = src.length; i < l; i++)
        {
            Object[] row = src[i];
            double rowVal;
            Object objVal = row[colIndex];
            if (objVal instanceof Integer)
            {
                rowVal = ((Integer)objVal).doubleValue();
            }
            else
            {
                rowVal = (Double)objVal;
            }
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
        _selector = ArrayListToObjectArray(dst);
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
    public Table selectWhenGreaterAndLess(int limit, Boolean GWithEqu, Boolean LWithEqu, double GValue, double LValue, int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object[]> dst = new ArrayList<>();
        for (int i = 0, l = src.length; i < l; i++)
        {
            Object[] row = src[i];
            double rowVal;
            Object objVal = row[colIndex];
            if (objVal instanceof Integer)
            {
                rowVal = ((Integer)objVal).doubleValue();
            }
            else
            {
                rowVal = (Double)objVal;
            }
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
        _selector = ArrayListToObjectArray(dst);
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
    public Table selectWhenLessOrGreater(int limit, Boolean LWithEqu, Boolean GWithEqu, double LValue, double GValue,
                                         int colIndex)
    {
        Object[][] src = _selector;
        if (src == null)
        {
            src = body;
        }
        ArrayList<Object[]> dst = new ArrayList<>();
        for (int i = 0, l = src.length; i < l; i++)
        {
            Object[] row = src[i];
            double rowVal;
            Object objVal = row[colIndex];
            if (objVal instanceof Integer)
            {
                rowVal = ((Integer)objVal).doubleValue();
            }
            else
            {
                rowVal = (Double)objVal;
            }
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
        _selector = ArrayListToObjectArray(dst);
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
            String cc = null; // current character
            while (cellIndexB < curLen)
            {
                cellIndexA = cellIndexB;
                cc = String.valueOf(ptr.charAt(ptrPos + cellIndexB));
                if (cc.equals("\r") && ptr.charAt(ptrPos + cellIndexB + 1) == '\n') // line is over
                {
                    cellIndexB += 2;
                    break;
                }
                if (cc.equals("\n")) // line is over
                {
                    cellIndexB += 1;
                    break;
                }
                if (cc.equals(FS)) // is separator
                {
                    cell = "";
                    int nextPos = ptrPos + cellIndexB + 1;
                    if (nextPos < maxLen)
                    {
                        cc = String.valueOf(ptr.charAt(nextPos));
                    }
                    else
                    {
                        cc = "\n"; // fix the bug when the last cell is empty
                    }
                    if (cellIndexA == 0 || cc.equals(FS) || cc.equals("\n")) // is empty cell
                    {
                        cellIndexB += 1;
                        cells.add("");
                    }
                    else if (cc.equals("\r") && ptr.charAt(ptrPos + cellIndexB + 2) == '\n') // is empty cell
                    {
                        cellIndexB += 2;
                        cells.add("");
                    }
                    else
                    {
                        cellIndexB += 1;
                    }
                }
                else if (cc.equals(FML)) // is double quote
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
                        int nextPos = ptrPos + cellIndexB + 1;
                        if (nextPos < maxLen)
                        {
                            if (String.valueOf(ptr.charAt(nextPos)).equals(FML)) // """" is normal double quote
                            {
                                cellIndexB += 2; // pass """"
                                continue;
                            }
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
        for (int i = 0, l = rawHead.size(); i < l; i++)
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
        for (int i = 0, l = rawBody.size(); i < l; i++)
        {
            ArrayList<String> row = rawBody.get(i);
            ArrayList<Object> item = new ArrayList<>();
            for (int j = 0, lenJ = row.size(); j < lenJ; j++)
            {
                String cell = row.get(j);
                Object newVal = cell;
                Boolean isEmptyCell = (cell.equals(null) || cell.equals(""));
                String ft = newHead.get(j).type;
                if (ft.equals("bool"))
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
                else if (ft.equals("int"))
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
                else if (ft.equals("number"))
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
                else if (ft.equals("json"))
                {
                    if (isEmptyCell)
                    {
                        newVal = null;
                    }
                    else
                    {
                        char cc = cell.charAt(0);
                        if (!(cc == '[' || cc == '{'))
                        {
                            System.out.print("[ACsv] Invalid json format:" + newHead.get(j).name + ',' + cell);
                            return null;
                        }
                        newVal = cell;
                    }
                }
                else if (ft.equals("strings"))
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
        table.head = (Field[]) newHead.toArray(new Field[0]);
        int numRows = newBody.size();
        int numCols = newHead.size();
        table.body = new Object[numRows][numCols];
        for (int i = 0; i < numRows; i++)
        {
            for (int j = 0; j < numCols; j++)
            {
                table.body[i][j] = newBody.get(i).get(j);
            }
        }
        return table;
    }
    /**
     * Check if the type is json.
     */
    private Boolean isJsonType(String v)
    {
        for (int i = 0, l = JSON_TYPES.length; i < l; i++)
        {
            if (JSON_TYPES[i].equals(v))
            {
                return true;
            }
        }
        return false;
    }
    /**
     * Convert to json variable instance.
     */
    private Object toJsonIns(String json)
    {
        Object ins = null;
        try {
            if (json.charAt(0) == '{')
            {
                JSONObject obj = new JSONObject(json);
                ins = obj;
            }
            else
            {
                JSONArray arr = new JSONArray(json);
                ins = arr;
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return ins;
    }
    /**
     * Convert ArrayList to ObjectArray.
     */
    private Object[][] ArrayListToObjectArray(ArrayList<Object[]> src)
    {
        int l = src.size();
        Object[][] dst = new Object[src.size()][];
        for (int i = 0; i < l; i++)
        {
            dst[i] = src.get(i);
        }
        return dst;
    }
}
