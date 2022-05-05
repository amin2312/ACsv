package acsv

import (
	"container/list"
	"strconv"
	"strings"
)

/**
 * Supported json field types.
 */
var TABLE_JSON_TYPES = []string{"json", "strings"}

/**
 * 1. Copyright (c) 2022 amin2312
 * 2. Version 1.0.0
 * 3. MIT License
 *
 * ACsv is a easy, fast and powerful csv parse library.
 */
type Table struct {
	/**
	 * The raw Content.
	 */
	Content string
	/**
	 * Parsed csv table Head.
	 */
	Head []*Field
	/**
	 * Parsed csv table Body.
	 */
	Body [][]interface{}
	/**
	 * Index Set(optimize for read).
	 */
	_indexSet map[int]map[interface{}][]interface{}
	/**
	 * Selected data(for Method Chaining).
	 */
	_selector [][]interface{}
}

/**
 * Merge a table.
 * <br/><b>Notice:</b> two tables' structure must be same.
 * @param b source table
 * @return THIS instance
 */
func (this *Table) merge(b Table) *Table {
	this.Body = append(this.Body, b.Body...)
	var index = strings.Index(b.Content, "\r\n")
	if index == -1 {
		index = strings.Index(b.Content, "\n")
	}
	var c = b.Content[index:]
	this.Content += c
	return this
}

/**
 * Create index for the specified column.
 * <br>This function is only valid for "selectWhenE" and "limit" param is 1.
 * <br>It will improve performance.
 * @param colIndex column index
 */
func (this *Table) createIndexAt(colIndex int) {
	var m = map[interface{}][]interface{}{}
	for i := range this.Body {
		var row = this.Body[i]
		var key = row[colIndex]
		m[key] = row
	}
	this._indexSet[colIndex] = m
}

/**
 * Get column index by specified field name.
 * @param name As name mean
 * @return column index
 */
func (this *Table) getColIndexBy(name string) int {
	for i := range this.Body {
		var field = this.Head[i]
		if field.Name == name {
			return i
		}
	}
	return -1
}

/**
 * Fetch a row object when the column's value is equal to the id value
 * @param values the specified value
 * @param colIndex specified column index
 * @return selected row object
 */
func (this *Table) id(value interface{}, colIndex int) interface{} {
	return this.selectWhenE(1, value, colIndex, nil).toFirstObj()
}

/**
 * Sort by selected rows.
 * @param colIndex the column index specified for sorting
 * @param sortType 0: asc, 1: desc
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) sortBy(colIndex int, sortType int) *Table {
	var l = len(this._selector)
	for i := 0; i < l; i++ {
		for j := 0; j < l-1; j++ {
			var ok = false
			var a float64
			var objA = this._selector[j][colIndex]
			if intVal, ok := objA.(int); ok {
				a = float64(intVal)
			} else {
				a = objA.(float64)
			}
			var b float64
			var objB = this._selector[j+1][colIndex]
			if intVal, ok := objB.(int); ok {
				b = float64(intVal)
			} else {
				b = objB.(float64)
			}
			if sortType == 0 && a > b {
				ok = true
			} else if sortType == 1 && a < b {
				ok = true
			}
			if ok {
				var temp = this._selector[j]
				this._selector[j] = this._selector[j+1]
				this._selector[j+1] = temp
			}
		}
	}
	return this
}

/**
 * Get current selector(it includes all selected results).
 * <br><b>Notice:</b> It be assigned after call "select..." function
 * @return current selector
 */
func (this *Table) getCurrentSelector() [][]interface{} {
	return this._selector
}

/**
 * Format data to row.
 */
func (this *Table) fmtRow(row []interface{}) []interface{} {
	var obj = make([]interface{}, len(this.Head))
	for i := range this.Head {
		var filed = this.Head[i]
		var ft = filed.Type
		var val0 = row[i]
		var val1 interface{} = nil
		if len(ft) > 0 && arrayIndexOf(TABLE_JSON_TYPES, ft) != -1 {
			if val0 != nil {
				val1 = val0 //haxe.Json.parse(val0)
			}
		} else {
			val1 = val0
		}
		obj[i] = val1
	}
	return obj
}

/**
 * Format data to obj.
 */
func (this *Table) fmtObj(row []interface{}) map[string]interface{} {
	var obj = map[string]interface{}{}
	for i := range this.Head {
		var field = this.Head[i]
		var name = field.Name
		var ft = field.Type
		var val0 = row[i]
		var val1 interface{} = nil
		if len(ft) > 0 && arrayIndexOf(TABLE_JSON_TYPES, ft) != -1 {
			if val0 != nil {
				val1 = val0 //haxe.Json.parse(val0)
			}
		} else {
			val1 = val0
		}
		obj[name] = val1
	}
	return obj
}

/**
 * Fetch first selected result to a row and return it.
 * @return first selected row data or nil
 */
func (this *Table) toFirstRow() []interface{} {
	var rzl []interface{} = nil
	if this._selector != nil && len(this._selector) > 0 {
		rzl = this.fmtRow(this._selector[0])
	}
	this._selector = nil
	return rzl
}

/**
 * Fetch last selected result to a row and return it.
 * @return last selected row data or nil
 */
func (this *Table) toLastRow() []interface{} {
	var rzl []interface{} = nil
	if this._selector != nil {
		var l = len(this._selector)
		if l > 0 {
			rzl = this.fmtRow(this._selector[l-1])
		}
	}
	this._selector = nil
	return rzl
}

/**
 * Fetch all selected results to the rows and return it.
 * @return a array of row data (even if the result is empty)
 */
func (this *Table) toRows() [][]interface{} {
	if this._selector == nil {
		return nil
	}
	var l = len(this._selector)
	var dst = make([][]interface{}, l)
	for i := 0; i < len(this._selector); i++ {
		var row = this._selector[i]
		dst[i] = this.fmtRow(row)
	}
	this._selector = nil
	return dst
}

/**
 * Fetch first selected result to a object and return it.
 * @return first selected row object or nil
 */
func (this *Table) toFirstObj() map[string]interface{} {
	var rzl map[string]interface{} = nil
	if this._selector != nil && len(this._selector) > 0 {
		rzl = this.fmtObj(this._selector[0])
	}
	this._selector = nil
	return rzl
}

/**
 * Fetch last selected result to a object and return it.
 * @return last selected row object or nil
 */
func (this *Table) toLastObj() interface{} {
	var rzl map[string]interface{} = nil
	if this._selector != nil {
		var l = len(this._selector)
		if l > 0 {
			rzl = this.fmtObj(this._selector[l-1])
		}
	}
	this._selector = nil
	return rzl
}

/**
 * Fetch all selected results to the objects and return it.
 * @return a array of row object (even if the result is empty)
 */
func (this *Table) toObjs() []map[string]interface{} {
	if this._selector == nil {
		return nil
	}
	var dst []map[string]interface{}
	for i := 0; i < len(this._selector); i++ {
		var row = this._selector[i]
		dst = append(dst, this.fmtObj(row))
	}
	this._selector = nil
	return dst
}

/**
 * Fetch all selected results to a new table.
 * @return a new table instance
 */
func (this *Table) toTable() *Table {
	if this._selector == nil {
		return nil
	}
	var t = new(Table)
	copy(t.Head, this.Head)
	t.Body = this._selector
	this._selector = nil
	return t
}

/**
 * Select all rows.
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectAll() *Table {
	this._selector = this.Body
	return this
}

/**
 * Select the first row.
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectFirstRow() *Table {
	this._selector = [][]interface{}{{this.Body[0]}}
	return this
}

/**
 * Select the last row.
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectLastRow() *Table {
	this._selector = [][]interface{}{{this.Body[len(this.Body)-1]}}
	return this
}

/**
 * Selects the specified <b>rows</b> by indices.
 * @param rowIndices specified row's indices
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectAt(rowIndices []int) *Table {
	var dst = list.New()
	var maxLen = len(this.Body)
	for i := range rowIndices {
		var rowIndex = rowIndices[i]
		if rowIndex >= 0 && rowIndex < maxLen {
			dst.PushBack(this.Body[rowIndex])
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
}

/**
 * Select the rows when the column's value is equal to any value of array.
 * @param limit maximum length of every selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
 * @param values the array of values
 * @param colIndex specified column index
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectWhenIn(limit int, values []interface{}, colIndex int) *Table {
	var dst = list.New()
	for i := range values {
		var value = values[i]
		this.selectWhenE(limit, value, colIndex, dst)
		this._selector = nil
	}
	this._selector = arrayListToObjectArray(dst)
	return this
}

/**
 * Select the rows when the column's value is equal to specified value.
 * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
 * @param value the specified value
 * @param colIndex specified column index
 * @param extraSelector extra selector, use it to save selected result
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectWhenE(limit int, value interface{}, colIndex int, extraSelector *list.List) *Table {
	var dst = extraSelector
	if dst == nil {
		dst = list.New()
	}
	// 1.check indexed set
	if limit == 1 {
		var m, ok = this._indexSet[colIndex]
		if ok {
			var val, ok = m[value]
			if ok {
				dst.PushBack(val)
			}
			this._selector = arrayListToObjectArray(dst)
			return this
		}
	}
	// 2.line-by-line scan
	var src = this._selector
	if src == nil {
		src = this.Body
	}
	for i := range src {
		var row = src[i]
		if row[colIndex] == value {
			dst.PushBack(row)
			limit--
			if limit == 0 {
				break
			}
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
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
func (this *Table) selectWhenE2(limit int, value1 interface{}, value2 interface{}, colIndex2 int, colIndex1 int) *Table {
	var src = this._selector
	if src == nil {
		src = this.Body
	}
	var dst = list.New()
	for i := range src {
		var row = src[i]
		if row[colIndex1] == value1 && row[colIndex2] == value2 {
			dst.PushBack(row)
			limit--
			if limit == 0 {
				break
			}
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
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
func (this *Table) selectWhenE3(limit int, value1 interface{}, value2 interface{}, value3 interface{}, colIndex3 int, colIndex2 int, colIndex1 int) *Table {
	var src = this._selector
	if src == nil {
		src = this.Body
	}
	var dst = list.New()
	for i := range src {
		var row = src[i]
		if row[colIndex1] == value1 && row[colIndex2] == value2 && row[colIndex3] == value3 {
			dst.PushBack(row)
			limit--
			if limit == 0 {
				break
			}
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
}

/**
 * Select the rows when the column's value is greater than specified value.
 * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
 * @param withEqu whether include equation
 * @param value the specified value
 * @param colIndex specified column index
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectWhenG(limit int, withEqu bool, value float64, colIndex int) *Table {
	var src = this._selector
	if src == nil {
		src = this.Body
	}
	var dst = list.New()
	for i := range src {
		var row = src[i]
		var rowVal float64
		var objVal = row[colIndex]
		if intVal, ok := objVal.(int); ok {
			rowVal = float64(intVal)
		} else {
			rowVal = objVal.(float64)
		}
		if rowVal > value || (withEqu && rowVal == value) {
			dst.PushBack(row)
			limit--
			if limit == 0 {
				break
			}
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
}

/**
 * Select the rows when the column's value is less than specified values.
 * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
 * @param withEqu whether include equation
 * @param value the specified value
 * @param colIndex specified column index
 * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
 */
func (this *Table) selectWhenL(limit int, withEqu bool, value float64, colIndex int) *Table {
	var src = this._selector
	if src == nil {
		src = this.Body
	}
	var dst = list.New()
	for i := range src {
		var row = src[i]
		var rowVal float64
		var objVal = row[colIndex]
		if intVal, ok := objVal.(int); ok {
			rowVal = float64(intVal)
		} else {
			rowVal = objVal.(float64)
		}
		if rowVal < value || (withEqu && rowVal == value) {
			dst.PushBack(row)
			limit--
			if limit == 0 {
				break
			}
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
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
func (this *Table) selectWhenGreaterAndLess(limit int, GWithEqu bool, LWithEqu bool, GValue float64, LValue float64, colIndex int) *Table {
	var src = this._selector
	if src == nil {
		src = this.Body
	}
	var dst = list.New()
	for i := range src {
		var row = src[i]
		var rowVal float64
		var objVal = row[colIndex]
		if intVal, ok := objVal.(int); ok {
			rowVal = float64(intVal)
		} else {
			rowVal = objVal.(float64)
		}
		var v1 = rowVal > GValue || (GWithEqu && rowVal == GValue)
		var v2 = rowVal < LValue || (LWithEqu && rowVal == LValue)
		if v1 && v2 {
			dst.PushBack(row)
			limit--
			if limit == 0 {
				break
			}
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
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
func (this *Table) selectWhenLessOrGreater(limit int, LWithEqu bool, GWithEqu bool, LValue float64, GValue float64, colIndex int) *Table {
	var src = this._selector
	if src == nil {
		src = this.Body
	}
	var dst = list.New()
	for i := range src {
		var row = src[i]
		var rowVal float64
		var objVal = row[colIndex]
		if intVal, ok := objVal.(int); ok {
			rowVal = float64(intVal)
		} else {
			rowVal = objVal.(float64)
		}
		var v1 = rowVal < LValue || (LWithEqu && rowVal == LValue)
		var v2 = rowVal > GValue || (GWithEqu && rowVal == GValue)
		if v1 || v2 {
			dst.PushBack(row)
			limit--
			if limit == 0 {
				break
			}
		}
	}
	this._selector = arrayListToObjectArray(dst)
	return this
}

/**
 * Parse csv conent.
 * @param Content As name mean
 * @param filedSeparator filed separator
 * @param filedMultiLineDelimiter filed multi-line delimiter
 * @return a table instance
 */
func ParseWith(content string, filedSeparator string, filedMultiLineDelimiter string) *Table {
	var table = arrayToRows(textToArray(content, filedSeparator, filedMultiLineDelimiter))
	table.Content = content
	return table
}
func Parse(content string) *Table {
	return ParseWith(content, ",", "\"")
}

/**
 * Convert text to array.
 */
func textToArray(text string, FS string, FML string) *list.List {
	var FMLs = FML + FML
	var arr = list.New()
	var maxLen = len(text)
	var ptr = text
	var ptrPos int
	for {
		var curLen = maxLen - ptrPos
		var cellIndexA int
		var cellIndexB int
		var cells = list.New()
		var cell string
		var cc string // current character
		for cellIndexB < curLen {
			cellIndexA = cellIndexB
			cc = string(ptr[ptrPos+cellIndexB])
			if cc == "\r" && ptr[ptrPos+cellIndexB+1] == '\n' { // line is over
				cellIndexB += 2
				break
			}
			if cc == "\n" { // line is over
				cellIndexB += 1
				break
			}
			if cc == FS { // is separator
				cell = ""
				var nextPos = ptrPos + cellIndexB + 1
				if nextPos < maxLen {
					cc = string(ptr[nextPos])
				} else {
					cc = "\n" // fix the bug when the last cell is empty
				}
				if cellIndexA == 0 || cc == FS || cc == "\n" { // is empty cell
					cellIndexB += 1
					cells.PushBack("")
				} else if cc == "\r" && ptr[ptrPos+cellIndexB+2] == '\n' { // is empty cell
					cellIndexB += 2
					cells.PushBack("")
				} else {
					cellIndexB += 1
				}
			} else if cc == FML { // is double quote
				// pass DQ
				cellIndexB++
				// 1.find the nearest double quote
				for {
					cellIndexB = strings.Index(ptr[ptrPos+cellIndexB:], FML)
					if cellIndexB == -1 {
						println("[ACsv] Invalid Double Quote")
						return nil
					}
					cellIndexB -= ptrPos
					var nextPos = ptrPos + cellIndexB + 1
					if nextPos < maxLen {
						if string(ptr[nextPos]) == FML { // """" is normal double quote
							cellIndexB += 2 // pass """"
							continue
						}
					}
					break
				}
				// 2.truncate the Content of double quote
				cell = ptr[ptrPos+cellIndexA+1 : ptrPos+cellIndexB]
				cell = strings.ReplaceAll(cell, FMLs, FML) // convert """" to ""
				cells.PushBack(cell)
				// pass DQ
				cellIndexB++
			} else { // is normal
				// 1.find the nearest comma and LF
				var indexA = strings.Index(ptr[ptrPos+cellIndexB:], FS)
				if indexA == -1 {
					indexA = curLen // is last cell
				} else {
					indexA -= ptrPos
				}
				var indexB = strings.Index(ptr[ptrPos+cellIndexB:], "\r\n")
				if indexB == -1 {
					indexB = strings.Index(ptr[ptrPos+cellIndexB:], "\n")
				}
				if indexB == -1 {
					indexB = curLen
				} else {
					indexB -= ptrPos
				}
				cellIndexB = indexA
				if indexB < indexA { // row is end
					cellIndexB = indexB
				}
				// 2.Truncate the cell contennt
				cell = ptr[ptrPos+cellIndexA : ptrPos+cellIndexB]
				cells.PushBack(cell)
			}
		}
		arr.PushBack(cells)
		// move to next position
		ptrPos += cellIndexB
		if ptrPos >= maxLen {
			break
		}
	}
	return arr
}

/**
 * Convert array to rows.
 */
func arrayToRows(arr *list.List) *Table {
	var rawHead = arr.Remove(arr.Front()).(*list.List)
	var rawBody = arr
	// parse Head
	var newHead = make([]*Field, rawHead.Len())
	for i, ptr := 0, rawHead.Front(); ptr != nil; i, ptr = i+1, ptr.Next() {
		var fullName = ptr.Value.(string)
		var parts = strings.Split(fullName, ":")
		var filed = new(Field)
		filed.FullName = fullName
		filed.Name = parts[0]
		filed.Type = ""
		if len(parts) == 2 {
			filed.Type = parts[1]
		}
		newHead[i] = filed
	}
	// parse Body
	var newBody = make([][]interface{}, rawBody.Len())
	for i, ptr := 0, rawBody.Front(); ptr != nil; i, ptr = i+1, ptr.Next() {
		var row = ptr.Value.(*list.List)
		var newRow = make([]interface{}, row.Len())
		for j, pt2 := 0, row.Front(); pt2 != nil; j, pt2 = j+1, pt2.Next() {
			var cell = pt2.Value.(string)
			var newVal interface{} = cell
			var isEmptyCell = cell == ""
			var ft = newHead[j].Type // avoid "type" keyword in other languages
			if ft == "bool" {
				if isEmptyCell || cell == "false" || cell == "0" {
					newVal = false
				} else {
					newVal = true
				}
			} else if ft == "int" {
				if isEmptyCell {
					newVal = 0
				} else {
					newVal, _ = strconv.Atoi(cell)
				}
			} else if ft == "number" {
				if isEmptyCell {
					newVal = 0
				} else {
					newVal, _ = strconv.ParseFloat(cell, 64)
				}
			} else if ft == "json" {
				if isEmptyCell {
					newVal = nil
				} else {
					var cc = cell[0]
					if !(cc == '[' || cc == '{') {
						println("[ACsv] Invalid json format:" + newHead[j].Name + "," + cell)
						return nil
					}
					newVal = cell
				}
			} else if ft == "strings" {
				if isEmptyCell {
					newVal = "[]"
				} else {
					newVal = "[\"" + strings.Join(strings.Split(cell, ","), "\",\"") + "\"]"
				}
			}
			newRow[j] = newVal
		}
		newBody[i] = newRow // update row
	}
	// create table
	var table = new(Table)
	table.Head = newHead
	table.Body = newBody
	return table
}
func arrayListToObjectArray(src *list.List) [][]interface{} {
	var l = src.Len()
	var dst = make([][]interface{}, l)
	for i, ptr := 0, src.Front(); ptr != nil; i, ptr = i+1, ptr.Next() {
		dst[i] = ptr.Value.([]interface{})
	}
	return dst
}

func arrayIndexOf(arr []string, element string) int {
	for i, v := range arr {
		if v == element {
			return i
		}
	}
	return -1
}
