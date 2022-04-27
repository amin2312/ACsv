<?php
namespace acsv
{
    /**
     * 1. Copyright (c) 2022 amin2312
     * 2. Version 1.0.0
     * 3. MIT License
     *
     * ACsv is a easy, fast and powerful csv parse library.
     */
    class Table
    {
        /**
         * Supported json field types.
         */
        private static $JSON_TYPES = ["json", "strings"];
        /**
         * The raw content.
         */
        public $content = null;
        /**
         * Parsed csv table Head.
         */
        public $head = [];
        /**
         * Parsed csv table Body.
         */
        public $body = [];
        /**
         * Index Set(optimize for read).
         */
        private $_indexSet = [];
        /**
         * Selected data(for Method Chaining).
         **/
        private $_selected = null;
        /**
         * Constructor.
         */
        public function __construct() {}
        /**
         * Merge a table.
         * <br/><b>Notice:</b> two tables' structure must be same.
         * @param b source table
         * @return THIS instance
         */
        public function merge($b)
        {
            $this->body = array_merge($this->body, $b->body);
            $index = strpos($b->content, "\r\n");
            if ($index === false)
            {
                $index = strpos($b->content, "\n");
            }
            $c = substr($b->content, $index);
            $this->content .= $c;
            return $this;
        }
        /**
         * Create index for the specified column.
         * <br>This function is only valid for "selectWhenE" and "limit" param is 1.
         * <br>It will improve performance.
         * @param colIndex column index
         */
        public function createIndexAt($colIndex)
        {
            $map = [];
            foreach ($this->body as $i => $row)
            {
                $key = $row[$colIndex];
                $map[$key] = $row;
            }
            $this->_indexSet[$colIndex] = $map;
        }
        /**
         * Get column index by specified field name.
         * @param name As name mean
         */
        public function getColIndexBy($name)
        {
            foreach ($this->head as $i => $field)
            {
                if ($field->name == $name)
                {
                    return $i;
                }
            }
            return -1;
        }
        /**
         * Sort by selected rows.
         * @param colIndex the column index specified for sorting
         * @param sortType 0: asc, 1: desc
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function sortBy($colIndex, $sortType)
        {
            $len = count($this->_selected);
            for ($i = 0; $i < $len; $i++)
            {
                for ($j = 0; $j < $len - 1; $j++)
                {
                    $ok = false;
                    $a = $this->_selected[$j][$colIndex];
                    $b = $this->_selected[$j + 1][$colIndex];
                    if ($sortType == 0 && $a > $b)
                    {
                        $ok = true;
                    }
                    else if ($sortType == 1 && $a < $b)
                    {
                        $ok = true;
                    }
                    if ($ok)
                    {
                        $temp = $this->_selected[$j];
                        $this->_selected[$j] = $this->_selected[$j + 1];
                        $this->_selected[$j + 1] = $temp;
                    }
                }
            }
            return $this;
        }
        /**
         * Get current selector(it includes all selected results).
         * <br><b>Notice:</b> It be assigned after call "select..." function
         */
        public function getCurrentSelector()
        {
            return $this->_selected;
        }
        /**
         * Format data to row.
         */
        private function fmtRow($row)
        {
            $obj = [];
            foreach ($this->head as $i => $field)
            {
                $type = $field->type;
                $val0 = $row[$i];
                $val1 = null;
                if ($type !== null && $type !== '' && array_search($type, self::$JSON_TYPES) !== false)
                {
                    if ($val0)
                    {
                        $val1 = json_decode($val0);
                    }
                }
                else
                {
                    $val1 = $val0;
                }
                array_push($obj, $val1);
            }
            return $obj;
        }
        /**
         * Format data to obj.
         */
        private function fmtObj($row)
        {
            $obj = [];
            foreach ($this->head as $i => $field)
            {
                $name = $field->name;
                $type = $field->type;
                $val0 = $row[$i];
                $val1 = null;
                if ($type !== null && $type !== '' && array_search($type, self::$JSON_TYPES) !== false)
                {
                    if ($val0)
                    {
                        $val1 = json_decode($val0);
                    }
                }
                else
                {
                    $val1 = $val0;
                }
                $obj[$name] = $val1;
            }
            return $obj;
        }
        /**
         * Fetch first selected result to a row and return it.
         */
        public function toFirstRow()
        {
            $rzl = null;
            if ($this->_selected != null && count($this->_selected) > 0)
            {
                $rzl = $this->fmtRow($this->_selected[0]);
            }
            $this->_selected = null;
            return $rzl;
        }
        /**
         * Fetch last selected result to a row and return it.
         */
        public function toLastRow()
        {
            $rzl = null;
            if ($this->_selected != null)
            {
                $len = count($this->_selected);
                if ($len > 0)
                {
                    $rzl = $this->fmtRow($this->_selected[$len - 1]);
                }
            }
            $this->_selected = null;
            return $rzl;
        }
        /**
         * Fetch all selected results to the rows and return it.
         */
        public function toRows()
        {
            if ($this->_selected == null)
            {
                return null;
            }
            $dst = [];
            foreach ($this->_selected as $i => $row)
            {
                array_push($dst, $this->fmtRow($row));
            }
            $this->_selected = null;
            return $dst;
        }
        /**
         * Fetch first selected result to a object and return it.
         */
        public function toFirstObj()
        {
            $rzl = null;
            if ($this->_selected != null && count($this->_selected) > 0)
            {
                $rzl = $this->fmtObj($this->_selected[0]);
            }
            $this->_selected = null;
            return $rzl;
        }
        /**
         * Fetch last selected result to a object and return it.
         */
        public function toLastObj()
        {
            $rzl = null;
            if ($this->_selected != null)
            {
                $len = count($this->_selected);
                if ($len > 0)
                {
                    $rzl = $this->fmtObj($this->_selected[$len - 1]);
                }
            }
            $this->_selected = null;
            return $rzl;
        }
        /**
         * Fetch all selected results to the objects and return it.
         */
        public function toObjs()
        {
            if ($this->_selected == null)
            {
                return null;
            }
            $dst = [];
            foreach ($this->_selected as $i => $row)
            {
                array_push($dst, $this->fmtObj($row));
            }
            $this->_selected = null;
            return $dst;
        }
        /**
         * Fetch all selected results to a new table.
         */
        public function toTable(): Table
        {
            if ($this->_selected == null)
            {
                return null;
            }
            $t = new Table();
            $t->head = $this->head;
            $t->body = $this->_selected;
            $this->_selected = null;
            return $t;
        }
        /**
         * Select all rows.
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectAll()
        {
            $this->_selected = $this->body;
            return $this;
        }
        /**
         * Select the first row.
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectFirstRow()
        {
            $this->_selected = [$this->body[0]];
            return $this;
        }
        /**
         * Select the last row.
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectLastRow()
        {
            $this->_selected = [$this->body[count($this->body) - 1]];
            return $this;
        }
        /**
         * Selects the specified <b>rows</b> by indices.
         * @param rowIndices specified row's indices
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectAt($rowIndices): Table
        {
            $dst = [];
            $len = count($this->body);
            foreach ($rowIndices as $i => $rowIndex)
            {
                if ($rowIndex >= 0 && $rowIndex < $len)
                {
                    array_push($dst, $this->body[$rowIndex]);
                }
            }
            $this->_selected = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is equal to any value of array.
         * @param limit maximum length of every selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param values the array of values
         * @param colIndex specified column index
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenIn($limit, $values, $colIndex = 0): Table
        {
            $rows = [];
            foreach ($values as $i => $value)
            {
                $this->selectWhenE($limit, $value, $colIndex, $rows);
                $this->_selected = null;
            }
            $this->_selected = $rows;
            return $this;
        }
        /**
         * Select the rows when the column's value is equal to specified value.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param value the specified value
         * @param colIndex specified column index
         * @param extraSelector extra selector, use it to save selected result
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenE($limit, $value, $colIndex = 0, &$extraSelector = null): Table
        {
            $dst = &$extraSelector;
            if ($dst == null)
            {
                $dst = [];
            }
            // 1.check indexed set
            if ($limit == 1)
            {
                if (isset($this->_indexSet[$colIndex]))
                {
                    $map = $this->_indexSet[$colIndex];
                    if ($map)
                    {
                        if (isset($map[$value]))
                        {
                            $val = $map[$value];
                            if ($val)
                            {
                                array_push($dst, $val);
                            }
                            $this->_selected = $dst;
                            return $this;
                        }
                    }
                }
            }
            // 2.line-by-line scan
            $src = $this->_selected;
            if ($src == null)
            {
                $src = $this->body;
            }
            foreach ($src as $i => $row)
            {
                if ($row[$colIndex] == $value)
                {
                    array_push($dst, $row);
                    $limit--;
                    if ($limit == 0)
                    {
                        break;
                    }
                }
            }
            $this->_selected = $dst;
            return $this;
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
        public function selectWhenE2($limit, $value1, $value2, $colIndex2 = 1, $colIndex1 = 0): Table
        {
            $src = $this->_selected;
            if ($src == null)
            {
                $src = $this->body;
            }
            $dst = [];
            foreach ($src as $i => $row)
            {
                if ($row[$colIndex1] == $value1 && $row[$colIndex2] == $value2)
                {
                    array_push($dst, $row);
                    $limit--;
                    if ($limit == 0)
                    {
                        break;
                    }
                }
            }
            $this->_selected = $dst;
            return $this;
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
        public function selectWhenE3($limit, $value1, $value2, $value3, $colIndex3 = 2, $colIndex2 = 1, $colIndex1 = 0): Table
        {
            $src = $this->_selected;
            if ($src == null)
            {
                $src = $this->body;
            }
            $dst = [];
            foreach ($src as $i => $row)
            {
                if ($row[$colIndex1] == $value1 && $row[$colIndex2] == $value2 && $row[$colIndex3] == $value3)
                {
                    array_push($dst, $row);
                    $limit--;
                    if ($limit == 0)
                    {
                        break;
                    }
                }
            }
            $this->_selected = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is greater than specified value.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param withEqu whether include equation
         * @param value the specified value
         * @param colIndex specified column index
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenG($limit, $withEqu, $value, $colIndex = 0): Table
        {
            $src = $this->_selected;
            if ($src == null)
            {
                $src = $this->body;
            }
            $dst = [];
            foreach ($src as $i => $row)
            {
                $rowVal = $row[$colIndex];
                if ($rowVal > $value || ($withEqu && $rowVal == $value))
                {
                    array_push($dst, $row);
                    $limit--;
                    if ($limit == 0)
                    {
                        break;
                    }
                }
            }
            $this->_selected = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is less than specified values.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param withEqu whether include equation
         * @param value the specified value
         * @param colIndex specified column index
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenL($limit, $withEqu, $value, $colIndex = 0): Table
        {
            $src = $this->_selected;
            if ($src == null)
            {
                $src = $this->body;
            }
            $dst = [];
            foreach ($src as $i => $row)
            {
                $rowVal = $row[$colIndex];
                if ($rowVal < $value || ($withEqu && $rowVal == $value))
                {
                    array_push($dst, $row);
                    $limit--;
                    if ($limit == 0)
                    {
                        break;
                    }
                }
            }
            $this->_selected = $dst;
            return $this;
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
        public function selectWhenGreaterAndLess($limit, $GWithEqu, $LWithEqu, $GValue, $LValue, $colIndex = 0): Table
        {
            $src = $this->_selected;
            if ($src == null)
            {
                $src = $this->body;
            }
            $dst = [];
            foreach ($src as $i => $row)
            {
                $rowVal = $row[$colIndex];
                $v1 = ($rowVal > $GValue || ($GWithEqu && $rowVal == $GValue));
                $v2 = ($rowVal < $LValue || ($LWithEqu && $rowVal == $LValue));
                if ($v1 && $v2)
                {
                    array_push($dst, $row);
                    $limit--;
                    if ($limit == 0)
                    {
                        break;
                    }
                }
            }
            $this->_selected = $dst;
            return $this;
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
        public function selectWhenLessOrGreater($limit, $LWithEqu, $GWithEqu, $LValue, $GValue, $colIndex = 0): Table
        {
            $src = $this->_selected;
            if ($src == null)
            {
                $src = $this->body;
            }
            $dst = [];
            foreach ($src as $i => $row)
            {
                $rowVal = $row[$colIndex];
                $v1 = ($rowVal < $LValue || ($LWithEqu && $rowVal == $LValue));
                $v2 = ($rowVal > $GValue || ($GWithEqu && $rowVal == $GValue));
                if ($v1 || $v2)
                {
                    array_push($dst, $row);
                    $limit--;
                    if ($limit == 0)
                    {
                        break;
                    }
                }
            }
            $this->_selected = $dst;
            return $this;
        }
        /**
         * Parse csv conent.
         * @param content As name mean
         * @param filedSeparator filed separator
         * @param filedMultiLineDelimiter filed multi-line delimiter
         */
        public static function Parse($content, $filedSeparator = ",", $filedMultiLineDelimiter = "\""): Table
        {
            $table = self::arrayToRows(self::textToArray($content, $filedSeparator, $filedMultiLineDelimiter));
            $table->content = $content;
            return $table;
        }
        /**
         * Convert text to array.
         */
        private static function textToArray($text, $FS = ",", $FML = "\"")
        {
            $FMLs = $FML . $FML;
            $arr = [];
            $maxLen = strlen($text);
            $ptr = $text;
            $ptrPos = 0;
            while (true)
            {
                $curLen = $maxLen - $ptrPos;
                $cellIndexA = 0;
                $cellIndexB = 0;
                $cells = [];
                $cell = null;
                $chr = null;
                while ($cellIndexB < $curLen)
                {
                    $cellIndexA = $cellIndexB;
                    $chr = $ptr[$ptrPos + $cellIndexB];
                    if ($chr == "\n" || $chr == "\r\n") // line is over
                    {
                        $cellIndexB += 1;
                        break;
                    }
                    if ($chr == "\r" && $ptr[$ptrPos + $cellIndexB + 1] == "\n") // line is over
                    {
                        $cellIndexB += 2;
                        break;
                    }
                    if ($chr == $FS) // is separator
                    {
                        $cell = "";
                        $nextPos = $ptrPos + $cellIndexB + 1;
                        if ($nextPos >= $maxLen)
                        {
                            $chr = "\n"; // fix the bug when the last cell is empty
                        }
                        else
                        {
                            $chr = $ptr[$nextPos];
                        }
                        if ($cellIndexA == 0 || $chr == $FS || $chr == "\n" || $chr == "\r\n") // is empty cell
                        {
                            $cellIndexB += 1;
                            array_push($cells, "");
                        }
                        else if ($chr == "\r" && $ptr[$ptrPos + $cellIndexB + 2] == "\n") // is empty cell
                        {
                            $cellIndexB += 2;
                            array_push($cells, "");
                        }
                        else
                        {
                            $cellIndexB += 1;
                        }
                    }
                    else if ($chr == $FML) // is double quote
                    {
                        // pass DQ
                        $cellIndexB++;
                        // 1.find the nearest double quote
                        while (true)
                        {
                            $cellIndexB = strpos($ptr, $FML, $ptrPos + $cellIndexB);
                            if ($cellIndexB === false)
                            {
                                echo("[ACsv] Invalid Double Quote");
                                return null;
                            }
                            $cellIndexB -= $ptrPos;
                            if ($ptr[$ptrPos + $cellIndexB + 1] == $FML) // """" is normal double quote
                            {
                                $cellIndexB += 2; // pass """"
                                continue;
                            }
                            break;
                        }
                        // 2.truncate the content of double quote
                        $cell = substr($ptr, $ptrPos + $cellIndexA + 1, $cellIndexB - $cellIndexA - 1);
                        $cell = str_replace($FMLs, $FML, $cell); // convert """" to ""
                        array_push($cells, $cell);
                        // pass DQ
                        $cellIndexB++;
                    }
                    else // is normal
                    {
                        // 1.find the nearest comma and LF
                        $indexA = strpos($ptr, $FS, $ptrPos + $cellIndexB);
                        if ($indexA === false)
                        {
                            $indexA = $curLen; // is last cell
                        }
                        else
                        {
                            $indexA -= $ptrPos;
                        }
                        $indexB = strpos($ptr, "\r\n", $ptrPos + $cellIndexB);
                        if ($indexB === false)
                        {
                            $indexB = strpos($ptr, "\n", $ptrPos + $cellIndexB);
                            if ($indexB === false)
                            {
                                $indexB = $curLen;
                            }
                            else
                            {
                                $indexB -= $ptrPos;
                            }
                        }
                        else
                        {
                            $indexB -= $ptrPos;
                        }
                        $cellIndexB = $indexA;
                        if ($indexB < $indexA) // row is end
                        {
                            $cellIndexB = $indexB;
                        }
                        // 2.Truncate the cell contennt
                        $cell = substr($ptr, $ptrPos + $cellIndexA, $cellIndexB - $cellIndexA);
                        array_push($cells, $cell);
                    }
                }
                array_push($arr, $cells);
                // move to next position
                $ptrPos += $cellIndexB;
                if ($ptrPos >= $maxLen)
                {
                    break;
                }
            }
            return $arr;
        }
        /**
         * Convert array to rows.
         */
        private static function arrayToRows($arr): Table
        {
            $head = array_shift($arr);
            $body = $arr;
            // parse head
            $fileds = [];
            foreach ($head as $i => $fullName)
            {
                $parts = explode(':', $fullName);
                $filed = new Field();
                $filed->fullName = $fullName;
                $filed->name = $parts[0];
                $filed->type = count($parts) == 2 ? $parts[1] : '';
                array_push($fileds, $filed);
            }
            // parse body
            foreach ($body as $i => &$row)
            {
                foreach ($row as $j => $cell)
                {
                    $newVal = $cell;
                    $type = $fileds[$j]->type;
                    $isEmptyCell = ($cell === null || $cell === '');
                    if ($type == 'bool')
                    {
                        if ($isEmptyCell || $cell == 'false' || $cell == '0')
                        {
                            $newVal = false;
                        }
                        else
                        {
                            $newVal = true;
                        }
                    }
                    else if ($type == 'int')
                    {
                        if ($isEmptyCell)
                        {
                            $newVal = 0;
                        }
                        else
                        {
                            $newVal = intval($newVal);
                        }
                    }
                    else if ($type == 'number')
                    {
                        if ($isEmptyCell)
                        {
                            $newVal = 0.0;
                        }
                        else
                        {
                            $newVal = floatval($newVal);
                        }
                    }
                    else if ($type == 'json')
                    {
                        if ($isEmptyCell)
                        {
                            $newVal = null;
                        }
                        else
                        {
                            $chr0 = $cell[0];
                            if (!($chr0 == '[' || $chr0 == '{'))
                            {
                                echo("[ACsv] Invalid json format:" . $fileds[$j]->name . ',' . $cell);
                                return null;
                            }
                            $newVal = $cell;
                        }
                    }
                    else if ($type == 'strings')
                    {
                        if ($isEmptyCell)
                        {
                            $newVal = '[]';
                        }
                        else
                        {
                            $newVal = '["' . implode("\",\"", explode(',', $cell)) . '"]';
                        }
                    }
                    $row[$j] = $newVal;
                }
                $body[$i] = $row; // update row
            }
            // create table
            $table = new Table();
            $table->head = $fileds;
            $table->body = $body;
            return $table;
        }
    }
    /**
     * 1. Copyright (c) 2022 amin2312
     * 2. Version 1.0.0
     * 3. MIT License
     *
     * CSV head field.
     */
    class Field
    {
        /**
         * Full Name.
         */
        public $fullName;
        /**
         * Name.
         */
        public $name;
        /**
         * Type.
         */
        public $type;
        /**
         * Constructor.
         */
        public function __construct() {}
    }
}
