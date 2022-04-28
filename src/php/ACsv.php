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
        private $_selector = null;
        /**
         * Constructor.
         */
        public function __construct() {}
        /**
         * Merge a table.
         * <br/><b>Notice:</b> two tables' structure must be same.
         * @param Table $b source table
         * @return Table THIS instance
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
         * @param int $colIndex column index
         * @return void
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
         * @param string $name As name mean
         * @return int column index
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
         * Fetch a row object when the column's value is equal to the id value
         * @param mixed $values the specified value
         * @param int $colIndex specified column index
         * @return object selected row object
         */
        public function id($value, $colIndex = 0)
        {
            return $this->selectWhenE(1, $value, $colIndex)->toFirstObj();
        }
        /**
         * Sort by selected rows.
         * @param int $colIndex the column index specified for sorting
         * @param int $sortType 0: asc, 1: desc
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function sortBy($colIndex, $sortType)
        {
            $len = count($this->_selector);
            for ($i = 0; $i < $len; $i++)
            {
                for ($j = 0; $j < $len - 1; $j++)
                {
                    $ok = false;
                    $a = $this->_selector[$j][$colIndex];
                    $b = $this->_selector[$j + 1][$colIndex];
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
                        $temp = $this->_selector[$j];
                        $this->_selector[$j] = $this->_selector[$j + 1];
                        $this->_selector[$j + 1] = $temp;
                    }
                }
            }
            return $this;
        }
        /**
         * Get current selector(it includes all selected results).
         * <br><b>Notice:</b> It be assigned after call "select..." function
         * @return array current selector
         */
        public function getCurrentSelector()
        {
            return $this->_selector;
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
         * @return array first selected row data
         */
        public function toFirstRow()
        {
            $rzl = null;
            if ($this->_selector != null && count($this->_selector) > 0)
            {
                $rzl = $this->fmtRow($this->_selector[0]);
            }
            $this->_selector = null;
            return $rzl;
        }
        /**
         * Fetch last selected result to a row and return it.
         * @return array last selected row data
         */
        public function toLastRow()
        {
            $rzl = null;
            if ($this->_selector != null)
            {
                $len = count($this->_selector);
                if ($len > 0)
                {
                    $rzl = $this->fmtRow($this->_selector[$len - 1]);
                }
            }
            $this->_selector = null;
            return $rzl;
        }
        /**
         * Fetch all selected results to the rows and return it.
         * @return array[] a array of row data
         */
        public function toRows()
        {
            if ($this->_selector == null)
            {
                return null;
            }
            $dst = [];
            foreach ($this->_selector as $i => $row)
            {
                array_push($dst, $this->fmtRow($row));
            }
            $this->_selector = null;
            return $dst;
        }
        /**
         * Fetch first selected result to a object and return it.
         * @return object first selected row object
         */
        public function toFirstObj()
        {
            $rzl = null;
            if ($this->_selector != null && count($this->_selector) > 0)
            {
                $rzl = $this->fmtObj($this->_selector[0]);
            }
            $this->_selector = null;
            return $rzl;
        }
        /**
         * Fetch last selected result to a object and return it.
         * @return object last selected row object
         */
        public function toLastObj()
        {
            $rzl = null;
            if ($this->_selector != null)
            {
                $len = count($this->_selector);
                if ($len > 0)
                {
                    $rzl = $this->fmtObj($this->_selector[$len - 1]);
                }
            }
            $this->_selector = null;
            return $rzl;
        }
        /**
         * Fetch all selected results to the objects and return it.
         * @return array[] a array of row object
         */
        public function toObjs()
        {
            if ($this->_selector == null)
            {
                return null;
            }
            $dst = [];
            foreach ($this->_selector as $i => $row)
            {
                array_push($dst, $this->fmtObj($row));
            }
            $this->_selector = null;
            return $dst;
        }
        /**
         * Fetch all selected results to a new table.
         * @return Table a new table instance
         */
        public function toTable()
        {
            if ($this->_selector == null)
            {
                return null;
            }
            $t = new Table();
            $t->head = $this->head;
            $t->body = $this->_selector;
            $this->_selector = null;
            return $t;
        }
        /**
         * Select all rows.
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectAll()
        {
            $this->_selector = $this->body;
            return $this;
        }
        /**
         * Select the first row.
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectFirstRow()
        {
            $this->_selector = [$this->body[0]];
            return $this;
        }
        /**
         * Select the last row.
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectLastRow()
        {
            $this->_selector = [$this->body[count($this->body) - 1]];
            return $this;
        }
        /**
         * Selects the specified <b>rows</b> by indices.
         * @param int[] $rowIndices specified row's indices
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectAt($rowIndices)
        {
            $dst = [];
            $maxLen = count($this->body);
            foreach ($rowIndices as $i => $rowIndex)
            {
                if ($rowIndex >= 0 && $rowIndex < $maxLen)
                {
                    array_push($dst, $this->body[$rowIndex]);
                }
            }
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is equal to any value of array.
         * @param int $limit maximum length of every selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param array $values the array of values
         * @param int $colIndex specified column index
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenIn($limit, $values, $colIndex = 0)
        {
            $dst = [];
            foreach ($values as $i => $value)
            {
                $this->selectWhenE($limit, $value, $colIndex, $dst);
                $this->_selector = null;
            }
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is equal to specified value.
         * @param int $limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param mixed $value the specified value
         * @param int $colIndex specified column index
         * @param array $extraSelector extra selector, use it to save selected result
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenE($limit, $value, $colIndex = 0, &$extraSelector = null)
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
                            $this->_selector = $dst;
                            return $this;
                        }
                    }
                }
            }
            // 2.line-by-line scan
            $src = $this->_selector;
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
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's values are equal to specified values.
         * @param int $limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param mixed $value1 first specified value
         * @param mixed $value2 second specified value
         * @param int $colIndex2 second specified column index
         * @param int $colIndex1 first specified column index
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenE2($limit, $value1, $value2, $colIndex2 = 1, $colIndex1 = 0)
        {
            $src = $this->_selector;
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
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's values are equal to specified values.
         * @param int $limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param mixed $value1 first specified value
         * @param mixed $value2 second specified value
         * @param mixed $value3 third specified value
         * @param int $colIndex3 third specified column index
         * @param int $colIndex2 second specified column index
         * @param int $colIndex1 first specified column index
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenE3($limit, $value1, $value2, $value3, $colIndex3 = 2, $colIndex2 = 1, $colIndex1 = 0)
        {
            $src = $this->_selector;
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
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is greater than specified value.
         * @param int $limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param bool $withEqu whether include equation
         * @param float $value the specified value
         * @param int $colIndex specified column index
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenG($limit, $withEqu, $value, $colIndex = 0)
        {
            $src = $this->_selector;
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
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is less than specified values.
         * @param int $limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param bool $withEqu whether include equation
         * @param float $value the specified value
         * @param int $colIndex specified column index
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenL($limit, $withEqu, $value, $colIndex = 0)
        {
            $src = $this->_selector;
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
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is greater than specified value <b>and</b> less than specified value.
         * @param int $limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param bool $GWithEqu whether greater and equal
         * @param bool $LWithEqu whether less and equal
         * @param float $GValue the specified greater value
         * @param float $LValue the specified less value
         * @param int $colIndex specified column index
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenGreaterAndLess($limit, $GWithEqu, $LWithEqu, $GValue, $LValue, $colIndex = 0)
        {
            $src = $this->_selector;
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
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Select the rows when the column's value is less than specified value <b>or</b> greater than specified value.
         * @param int $limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param bool $LWithEqu whether less and equal
         * @param bool $GWithEqu whether greater and equal
         * @param float $LValue the specified less value
         * @param float $GValue the specified greater value
         * @param int $colIndex specified column index
         * @return Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        public function selectWhenLessOrGreater($limit, $LWithEqu, $GWithEqu, $LValue, $GValue, $colIndex = 0)
        {
            $src = $this->_selector;
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
            $this->_selector = $dst;
            return $this;
        }
        /**
         * Parse csv conent.
         * @param strintg $content As name mean
         * @param strintg $filedSeparator filed separator
         * @param strintg $filedMultiLineDelimiter filed multi-line delimiter
         * @return Table a table instance
         */
        public static function Parse($content, $filedSeparator = ",", $filedMultiLineDelimiter = "\"")
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
        private static function arrayToRows($arr)
        {
            $rawHead = array_shift($arr);
            $srcBody = $arr;
            // parse head
            $newHead = [];
            foreach ($rawHead as $i => $fullName)
            {
                $parts = explode(':', $fullName);
                $filed = new Field();
                $filed->fullName = $fullName;
                $filed->name = $parts[0];
                $filed->type = count($parts) == 2 ? $parts[1] : '';
                array_push($newHead, $filed);
            }
            // parse body
            foreach ($srcBody as $i => &$row)
            {
                foreach ($row as $j => $cell)
                {
                    $newVal = $cell;
                    $type = $newHead[$j]->type;
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
                            $newVal = intval($cell);
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
                            $newVal = floatval($cell);
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
                                echo("[ACsv] Invalid json format:" . $newHead[$j]->name . ',' . $cell);
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
                $srcBody[$i] = $row; // update row
            }
            // create table
            $table = new Table();
            $table->head = $newHead;
            $table->body = $srcBody;
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
