namespace acsv
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using Newtonsoft.Json.Linq;
    /**
     * 1. Copyright (c) 2022 amin2312
     * 2. Version 1.0.0
     * 3. MIT License
     *
     * CSV head field.
     */
    public class Field
    {
        /**
         * Full Name.
         */
        public string fullName;
        /**
         * Name.
         */
        public string name;
        /**
         * Type.
         */
        public string type;
        /**
         * Constructor.
         */
        public Field() {}
    }
    /**
     * 1. Copyright (c) 2022 amin2312
     * 2. Version 1.0.0
     * 3. MIT License
     *
     * ACsv is a easy, fast and powerful csv parse library.
     */
    public class Table
    {
        /**
         * Supported json field types.
         */
        private static string[] JSON_TYPES = {"json", "strings"};
        /**
         * The raw content.
         */
        public string content;
        /**
         * Parsed csv table Head.
         */
        public Field[] head;
        /**
         * Parsed csv table Body.
         */
        public object[][] body;
        /**
         * Index Set(optimize for read).
         */
        private Dictionary<int, Dictionary<object, object[]>> _indexSet = new Dictionary<int, Dictionary<object, object[]>>();
        /**
         * Selected data(for Method Chaining).
         */
        private object[][] _selector;
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
            object[][] both = new object[this.body.GetLength(0) + b.body.GetLength(0)][];
            this.body.CopyTo(both, 0);
            b.body.CopyTo(both, this.body.GetLength(0));
            this.body = both;
            int index = b.content.IndexOf("\r\n");
            if (index == -1)
            {
                index = b.content.IndexOf("\n");
            }
            string c = b.content.Substring(index);
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
            Dictionary<object, object[]> m = new Dictionary<object, object[]>();
            for (int i = 0, l = this.body.GetLength(0); i < l; i++)
            {
                object[] row = this.body[i];
                object key = row[colIndex];
                m[key] = row;
            }
            _indexSet[colIndex] = m;
        }
        /**
         * Get column index by specified field name.
         *
         * @param name As name mean
         * @return column index
         */
        public int getColIndexBy(string name)
        {
            for (int i = 0, l = this.head.Length; i < l; i++)
            {
                Field field = this.head[i];
                if (field.name.Equals(name))
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
        public Dictionary<string, object> id(object value, int colIndex)
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
            int l = _selector.GetLength(0);
            for (int i = 0; i < l; i++)
            {
                for (int j = 0; j < l - 1; j++)
                {
                    bool ok = false;
                    double a;
                    object objA = _selector[j][colIndex];
                    if (objA is int)
                    {
                        a = Convert.ToDouble(objA);
                    }
                    else
                    {
                        a = (double)objA;
                    }
                    double b;
                    object objB = _selector[j + 1][colIndex];
                    if (objB is int)
                    {
                        b = Convert.ToDouble(objB);
                    }
                    else
                    {
                        b = (double)objB;
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
                        object[] temp = _selector[j];
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
        public object[][] getCurrentSelector()
        {
            return _selector;
        }
        /**
         * Format data to row.
         */
        private object[] fmtRow(object[] row)
        {
            ArrayList obj = new ArrayList();
            for (int i = 0, l = this.head.Length; i < l; i++)
            {
                Field filed = this.head[i];
                string ft = filed.type;
                object val0 = row[i];
                object val1 = null;
                if (ft != null && ft.Length > 0 && isJsonType(ft))
                {
                    if (val0 != null)
                    {
                        val1 = toJsonIns((string)val0);
                    }
                }
                else
                {
                    val1 = val0;
                }
                obj.Add(val1);
            }
            return obj.ToArray();
        }
        /**
         * Format data to obj.
         */
        private Dictionary<string, object> fmtObj(object[] row)
        {
            Dictionary<string, object> obj = new Dictionary<string, object>();
            for (int i = 0, l = this.head.Length; i < l; i++)
            {
                Field field = this.head[i];
                string name = field.name;
                string ft = field.type;
                object val0 = row[i];
                object val1 = null;
                if (ft != null && ft.Length > 0 && isJsonType(ft))
                {
                    if (val0 != null)
                    {
                        val1 = toJsonIns((string)val0);
                    }
                }
                else
                {
                    val1 = val0;
                }
                obj[name] = val1;
            }
            return obj;
        }
        /**
         * Fetch first selected result to a row and return it.
         *
         * @return first selected row data or null
         */
        public object[] toFirstRow()
        {
            object[] rzl = null;
            if (_selector != null && _selector.GetLength(0) > 0)
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
        public object[] toLastRow()
        {
            object[] rzl = null;
            if (_selector != null)
            {
                int l = _selector.GetLength(0);
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
        public object[][] toRows()
        {
            if (_selector == null)
            {
                return null;
            }
            int l = _selector.GetLength(0);
            object[][] dst = new object[l][];
            for (int i = 0; i < l; i++)
            {
                object[] row = _selector[i];
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
        public Dictionary<string, object> toFirstObj()
        {
            Dictionary<string, object> rzl = null;
            if (_selector != null && _selector.GetLength(0) > 0)
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
        public Dictionary<string, object> toLastObj()
        {
            Dictionary<string, object> rzl = null;
            if (_selector != null)
            {
                int l = _selector.GetLength(0);
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
        public Dictionary<string, object>[] toObjs()
        {
            if (_selector == null)
            {
                return null;
            }
            int l = _selector.GetLength(0);
            Dictionary<string, object>[] dst = new Dictionary<string, object>[l];
            for (int i = 0; i < l; i++)
            {
                object[] row = _selector[i];
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
            t.head = (Field[]) this.head.Clone();
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
            _selector = new object[][]{body[0]};
            return this;
        }
        /**
         * Select the last row.
         *
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public Table selectLastRow()
        {
            _selector = new object[][]{body[body.GetLength(0) - 1]};
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
            ArrayList dst = new ArrayList();
            int maxLen = this.body.GetLength(0);
            for (int i = 0, l = rowIndices.Length; i < l; i++)
            {
                int rowIndex = rowIndices[i];
                if (rowIndex >= 0 && rowIndex < maxLen)
                {
                    dst.Add(this.body[rowIndex]);
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
        public Table selectWhenIn(int limit, object[] values, int colIndex)
        {
            ArrayList dst = new ArrayList();
            for (int i = 0, l = values.Length; i < l; i++)
            {
                object value = values[i];
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
        public Table selectWhenE(int limit, object value, int colIndex, ArrayList extraSelector)
        {
            ArrayList dst = extraSelector;
            if (dst == null)
            {
                dst = new ArrayList();
            }
            // 1.check indexed set
            if (limit == 1)
            {
                if (_indexSet.ContainsKey(colIndex))
                {
                    Dictionary<object, object[]> m = _indexSet[colIndex];
                    if (m != null)
                    {
                        if (m.ContainsKey(value))
                        {
                            object[] val = m[value];
                            if (val != null)
                            {
                                dst.Add(val);
                            }
                            _selector = ArrayListToObjectArray(dst);
                            return this;
                        }
                    }
                }
            }
            // 2.line-by-line scan
            object[][] src = _selector;
            if (src == null)
            {
                src = body;
            }
            for (int i = 0, l = src.GetLength(0); i < l; i++)
            {
                object[] row = src[i];
                if (value.Equals(row[colIndex]))
                {
                    dst.Add(row);
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
        public Table selectWhenE2(int limit, object value1, object value2, int colIndex2, int colIndex1)
        {
            object[][] src = _selector;
            if (src == null)
            {
                src = body;
            }
            ArrayList dst = new ArrayList();
            for (int i = 0, l = src.GetLength(0); i < l; i++)
            {
                object[] row = src[i];
                if (value1.Equals(row[colIndex1]) && value2.Equals(row[colIndex2]))
                {
                    dst.Add(row);
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
        public Table selectWhenE3(int limit, object value1, object value2, object value3, int colIndex3, int colIndex2, int colIndex1)
        {
            object[][] src = _selector;
            if (src == null)
            {
                src = body;
            }
            ArrayList dst = new ArrayList();
            for (int i = 0, l = src.GetLength(0); i < l; i++)
            {
                object[] row = src[i];
                if (value1.Equals(row[colIndex1]) && value2.Equals(row[colIndex2]) && value3.Equals(row[colIndex3]))
                {
                    dst.Add(row);
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
        public Table selectWhenG(int limit, bool withEqu, double value, int colIndex)
        {
            object[][] src = _selector;
            if (src == null)
            {
                src = body;
            }
            ArrayList dst = new ArrayList();
            for (int i = 0, l = src.GetLength(0); i < l; i++)
            {
                object[] row = src[i];
                double rowVal;
                object objVal = row[colIndex];
                if (objVal is int)
                {
                    rowVal = Convert.ToDouble(objVal);
                }
                else
                {
                    rowVal = (double)objVal;
                }
                if (rowVal > value || (withEqu && rowVal == value))
                {
                    dst.Add(row);
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
        public Table selectWhenL(int limit, bool withEqu, double value, int colIndex)
        {
            object[][] src = _selector;
            if (src == null)
            {
                src = body;
            }
            ArrayList dst = new ArrayList();
            for (int i = 0, l = src.GetLength(0); i < l; i++)
            {
                object[] row = src[i];
                double rowVal;
                object objVal = row[colIndex];
                if (objVal is int)
                {
                    rowVal = Convert.ToDouble(objVal);
                }
                else
                {
                    rowVal = (double)objVal;
                }
                if (rowVal < value || (withEqu && rowVal == value))
                {
                    dst.Add(row);
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
        public Table selectWhenGreaterAndLess(int limit, bool GWithEqu, bool LWithEqu, double GValue, double LValue, int colIndex)
        {
            object[][] src = _selector;
            if (src == null)
            {
                src = body;
            }
            ArrayList dst = new ArrayList();
            for (int i = 0, l = src.GetLength(0); i < l; i++)
            {
                object[] row = src[i];
                double rowVal;
                object objVal = row[colIndex];
                if (objVal is int)
                {
                    rowVal = Convert.ToDouble(objVal);
                }
                else
                {
                    rowVal = (double)objVal;
                }
                bool v1 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
                bool v2 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
                if (v1 && v2)
                {
                    dst.Add(row);
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
        public Table selectWhenLessOrGreater(int limit, bool LWithEqu, bool GWithEqu, double LValue, double GValue,
                                            int colIndex)
        {
            object[][] src = _selector;
            if (src == null)
            {
                src = body;
            }
            ArrayList dst = new ArrayList();
            for (int i = 0, l = src.GetLength(0); i < l; i++)
            {
                object[] row = src[i];
                double rowVal;
                object objVal = row[colIndex];
                if (objVal is int)
                {
                    rowVal = Convert.ToDouble(objVal);
                }
                else
                {
                    rowVal = (double)objVal;
                }
                bool v1 = (rowVal < LValue || (LWithEqu && rowVal == LValue));
                bool v2 = (rowVal > GValue || (GWithEqu && rowVal == GValue));
                if (v1 || v2)
                {
                    dst.Add(row);
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
        public static Table Parse(string content, string filedSeparator, string filedMultiLineDelimiter)
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
        public static Table Parse(string content)
        {
            return Parse(content, ",", "\"");
        }
        /**
         * Convert text to array.
         */
        static private ArrayList textToArray(string text, string FS, string FML)
        {
            string FMLs = FML + FML;
            ArrayList arr = new ArrayList();
            int maxLen = text.Length;
            string ptr = text;
            int ptrPos = 0;
            while (true)
            {
                int curLen = maxLen - ptrPos;
                int cellIndexA = 0;
                int cellIndexB = 0;
                ArrayList cells = new ArrayList();
                string cell = null;
                string cc = null; // current character
                while (cellIndexB < curLen)
                {
                    cellIndexA = cellIndexB;
                    cc = ptr[ptrPos + cellIndexB].ToString();
                    if (cc.Equals("\r") && ptr[ptrPos + cellIndexB + 1] == '\n') // line is over
                    {
                        cellIndexB += 2;
                        break;
                    }
                    if (cc.Equals("\n")) // line is over
                    {
                        cellIndexB += 1;
                        break;
                    }
                    if (cc.Equals(FS)) // is separator
                    {
                        cell = "";
                        int nextPos = ptrPos + cellIndexB + 1;
                        if (nextPos < maxLen)
                        {
                            cc = ptr[nextPos].ToString();
                        }
                        else
                        {
                            cc = "\n"; // fix the bug when the last cell is empty
                        }
                        if (cellIndexA == 0 || cc.Equals(FS) || cc.Equals("\n")) // is empty cell
                        {
                            cellIndexB += 1;
                            cells.Add("");
                        }
                        else if (cc.Equals("\r") && ptr[ptrPos + cellIndexB + 2] == '\n') // is empty cell
                        {
                            cellIndexB += 2;
                            cells.Add("");
                        }
                        else
                        {
                            cellIndexB += 1;
                        }
                    }
                    else if (cc.Equals(FML)) // is double quote
                    {
                        // pass DQ
                        cellIndexB++;
                        // 1.find the nearest double quote
                        while (true)
                        {
                            cellIndexB = ptr.IndexOf(FML, ptrPos + cellIndexB);
                            if (cellIndexB == -1)
                            {
                                Console.WriteLine("[ACsv] Invalid double Quote");
                                return null;
                            }
                            cellIndexB -= ptrPos;
                            int nextPos = ptrPos + cellIndexB + 1;
                            if (nextPos < maxLen)
                            {
                                if (ptr[nextPos].ToString().Equals(FML)) // """" is normal double quote
                                {
                                    cellIndexB += 2; // pass """"
                                    continue;
                                }
                            }
                            break;
                        }
                        // 2.truncate the content of double quote
                        cell = ptr.Substring(ptrPos + cellIndexA + 1, cellIndexB - cellIndexA - 1);
                        cell = cell.Replace(FMLs, FML); // convert """" to ""
                        cells.Add(cell);
                        // pass DQ
                        cellIndexB++;
                    }
                    else // is normal
                    {
                        // 1.find the nearest comma and LF
                        int indexA = ptr.IndexOf(FS, ptrPos + cellIndexB);
                        if (indexA == -1)
                        {
                            indexA = curLen; // is last cell
                        }
                        else
                        {
                            indexA -= ptrPos;
                        }
                        int indexB = ptr.IndexOf("\r\n", ptrPos + cellIndexB);
                        if (indexB == -1)
                        {
                            indexB = ptr.IndexOf("\n", ptrPos + cellIndexB);
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
                        cell = ptr.Substring(ptrPos + cellIndexA, cellIndexB - cellIndexA);
                        cells.Add(cell);
                    }
                }
                arr.Add(cells);
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
        static private Table arrayToRows(ArrayList arr)
        {
            ArrayList rawHead = (ArrayList) arr[0];
            arr.RemoveAt(0);
            ArrayList rawBody = arr;
            // parse head
            ArrayList newHead = new ArrayList();
            for (int i = 0, l = rawHead.Count; i < l; i++)
            {
                string fullName = (string) rawHead[i];
                string[] parts = fullName.Split(':');
                Field filed = new Field();
                filed.fullName = fullName;
                filed.name = parts[0];
                filed.type = parts.Length == 2 ? parts[1] : "";
                newHead.Add(filed);
            }
            // parse body
            ArrayList newBody = new ArrayList();
            for (int i = 0, l = rawBody.Count; i < l; i++)
            {
                ArrayList row = (ArrayList)rawBody[i];
                ArrayList item = new ArrayList();
                for (int j = 0, lenJ = row.Count; j < lenJ; j++)
                {
                    string cell = (string)row[j];
                    object newVal = cell;
                    bool isEmptyCell = (cell.Equals(null) || cell.Equals(""));
                    string ft = ((Field)newHead[j]).type;
                    if (ft.Equals("bool"))
                    {
                        if (isEmptyCell || cell.Equals("false") || cell.Equals("0"))
                        {
                            newVal = false;
                        }
                        else
                        {
                            newVal = true;
                        }
                    }
                    else if (ft.Equals("int"))
                    {
                        if (isEmptyCell)
                        {
                            newVal = 0;
                        }
                        else
                        {
                            newVal = Convert.ToInt32(cell);
                        }
                    }
                    else if (ft.Equals("number"))
                    {
                        if (isEmptyCell)
                        {
                            newVal = 0.0;
                        }
                        else
                        {
                            newVal = Convert.ToDouble(cell);
                        }
                    }
                    else if (ft.Equals("json"))
                    {
                        if (isEmptyCell)
                        {
                            newVal = null;
                        }
                        else
                        {
                            char cc = cell[0];
                            if (!(cc == '[' || cc == '{'))
                            {
                                Console.WriteLine("[ACsv] Invalid json format:" + ((Field)newHead[j]).name + ',' + cell);
                                return null;
                            }
                            newVal = cell;
                        }
                    }
                    else if (ft.Equals("strings"))
                    {
                        if (isEmptyCell)
                        {
                            newVal = "[]";
                        }
                        else
                        {
                            newVal = "[\"" + String.Join("\",\"", cell.Split(',')) + "\"]";
                        }
                    }
                    item.Add(newVal);
                }
                newBody.Add(item); // update row
            }
            // create table
            Table table = new Table();
            table.head = (Field[]) newHead.ToArray(typeof(Field));
            int numRows = newBody.Count;
            int numCols = newHead.Count;
            table.body = new object[numRows][];
            for (int i = 0; i < numRows; i++)
            {
                table.body[i] = new object[numCols];
                for (int j = 0; j < numCols; j++)
                {
                    table.body[i][j] = ((ArrayList)newBody[i])[j];
                }
            }
            return table;
        }
        /**
         * Check if the type is json.
         */
        private bool isJsonType(string v)
        {
            for (int i = 0, l = JSON_TYPES.Length; i < l; i++)
            {
                if (JSON_TYPES[i].Equals(v))
                {
                    return true;
                }
            }
            return false;
        }
        /**
         * Convert to json variable instance.
         */
        private object toJsonIns(string json)
        {
            object ins = null;
            if (json[0] == '{')
            {
                JObject obj = JObject.Parse(json);
                ins = obj;
            }
            else
            {
                JArray arr = JArray.Parse(json);
                ins = arr;
            }
            return ins;
        }
        /**
         * Convert ArrayList to ObjectArray.
         */
        private object[][] ArrayListToObjectArray(ArrayList src)
        {
            int l = src.Count;
            object[][] dst = new object[src.Count][];
            for (int i = 0; i < l; i++)
            {
                dst[i] = (object[])src[i];
            }
            return dst;
        }
    }
}