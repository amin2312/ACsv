# -*- coding: UTF-8 -*-
import json
'''
1. Copyright (c) 2022 amin2312
2. Version 1.0.0
3. MIT License

ACsv is a easy, fast and powerful csv parse library.

'''
class Table:
    '''
    The raw content.
    '''
    content = None
    '''
    Parsed csv table Head.
    '''
    head = []
    '''
    Parsed csv table Body.
    '''
    body = []
    '''
    Index Set(optimize for read).
    '''
    _indexSet = {}
    '''
    Selected data(for Method Chaining).
    '''
    _selector = None
    '''
    Constructor.
    '''
    def __init__(self):
        self.content = None
    '''
    Merge a table.
    <br/><b>Notice:</b> two tables' structure must be same.

    :param b: source table
    :return: THIS instance
    '''
    def merge(self, b):
        self.body = self.body + b.body
        index = b.content.find("\r\n")
        if (index == -1):
            index = b.content.find("\n")
        c = b.content[index:]
        self.content += c
        return self
    '''
    Create index for the specified column.
    <br>This function is only valid for "selectWhenE" and "limit" param is 1.
    <br>It will improve performance.

    :param colIndex: column index
    :return:
    '''
    def createIndexAt(self, colIndex):
        m = {}
        for row in self.body:
            key = row[colIndex]
            m[key] = row
        self._indexSet[colIndex] = m
    '''
    Get column index by specified field name.

    :param name: As name mean
    :return: column index
    '''
    def getColIndexBy(self, name):
        for i, field in enumerate(self.head):
            if (field.name == name):
                return i
        return -1
    '''
    Fetch a row object when the column's value is equal to the id value

    :param values: the specified value
    :param colIndex: specified column index
    :return: selected row object
    '''
    def id(self, value, colIndex = 0):
        return self.selectWhenE(1, value, colIndex).toFirstObj()
    '''
    Sort by selected rows.

    :param colIndex: the column index specified for sorting
    :param sortType: 0: asc, 1: desc
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def sortBy(self, colIndex, sortType):
        l = len(self._selector)
        for i in range(l):
            for j in range(l - 1):
                ok = False
                a = self._selector[j][colIndex]
                b = self._selector[j + 1][colIndex]
                if (sortType == 0 and a > b):
                    ok = True
                elif (sortType == 1 and a < b):
                    ok = True
                if (ok):
                    temp = self._selector[j]
                    self._selector[j] = self._selector[j + 1]
                    self._selector[j + 1] = temp
        return self
    '''
    Get current selector(it includes all selected results).
    <br><b>Notice:</b> It be assigned after call "select..." function

    :return: current selector
    '''
    def getCurrentSelector(self):
        return self._selector
    '''
    Format data to row.
    '''
    def fmtRow(self, row):
        obj = []
        for i, field in enumerate(self.head):
            ft = field.type
            val0 = row[i]
            val1 = None
            if (ft != None and ft != '' and (Table.JSON_TYPES.index(ft) if ft in Table.JSON_TYPES else -1) != -1):
                if (val0):
                    val1 = json.loads(val0)
            else:
                val1 = val0
            obj.append(val1)
        return obj
    '''
    Format data to obj.
    '''
    def fmtObj(self, row):
        obj = {}
        for i, field in enumerate(self.head):
            name = field.name
            ft = field.type
            val0 = row[i]
            val1 = None
            if (ft != None and ft != '' and (Table.JSON_TYPES.index(ft) if ft in Table.JSON_TYPES else -1) != -1):
                if (val0):
                    val1 = json.loads(val0)
            else:
                val1 = val0
            obj[name] = val1
        return obj
    '''
    Fetch first selected result to a row and return it.

    :return: first selected row data or None
    '''
    def toFirstRow(self, ):
        rzl = None
        if (self._selector != None and len(self._selector) > 0):
            rzl = self.fmtRow(self._selector[0])
        self._selector = None
        return rzl
    '''
    Fetch last selected result to a row and return it.

    :return: last selected row data or None
    '''
    def toLastRow(self, ):
        rzl = None
        if (self._selector != None):
            l = len(self._selector)
            if (l > 0):
                rzl = self.fmtRow(self._selector[l - 1])
        self._selector = None
        return rzl
    '''
    Fetch all selected results to the rows and return it.

    :return: a array of row data (even if the result is empty)
    '''
    def toRows(self, ):
        if (self._selector == None):
            return None
        dst = []
        for row in self._selector:
            dst.append(self.fmtRow(row))
        self._selector = None
        return dst
    '''
    Fetch first selected result to a object and return it.

    :return: first selected row object or None
    '''
    def toFirstObj(self, ):
        rzl = None
        if (self._selector != None and len(self._selector) > 0):
            rzl = self.fmtObj(self._selector[0])
        self._selector = None
        return rzl
    '''
    Fetch last selected result to a object and return it.

    :return: last selected row object or None
    '''
    def toLastObj(self, ):
        rzl = None
        if (self._selector != None):
            l = len(self._selector)
            if (l > 0):
                rzl = self.fmtObj(self._selector[l - 1])
        self._selector = None
        return rzl
    '''
    Fetch all selected results to the objects and return it.

    :return: a array of row object (even if the result is empty)
    '''
    def toObjs(self, ):
        if (self._selector == None):
            return None
        dst = []
        for row in self._selector:
            dst.append(self.fmtObj(row))
        self._selector = None
        return dst
    '''
    Fetch all selected results to a new table.

    :return: a new table instance
    '''
    def toTable(self, ):
        if (self._selector == None):
            return None
        t = Table()
        t.head = self.head
        t.body = self._selector
        self._selector = None
        return t
    '''
    Select all rows.

    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectAll(self, ):
        self._selector = self.body
        return self
    '''
    Select the first row.

    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectFirstRow(self, ):
        self._selector = [self.body[0]]
        return self
    '''
    Select the last row.

    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectLastRow(self, ):
        self._selector = [self.body[len(self.body) - 1]]
        return self
    '''
    Selects the specified <b>rows</b> by indices.

    :param rowIndices: specified row's indices
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectAt(self, rowIndices):
        dst = []
        maxLen = len(self.body)
        for rowIndex in rowIndices:
            if (rowIndex >= 0 and rowIndex < maxLen):
                dst.append(self.body[rowIndex])
        self._selector = dst
        return self
    '''
    Select the rows when the column's value is equal to any value of array.

    :param limit: maximum length of every selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param values: the array of values
    :param colIndex: specified column index
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenIn(self, limit, values, colIndex = 0):
        dst = []
        for value in values:
            self.selectWhenE(limit, value, colIndex, dst)
            self._selector = None
        self._selector = dst
        return self
    '''
    Select the rows when the column's value is equal to specified value.

    :param limit: maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param value: the specified value
    :param colIndex: specified column index
    :param extraSelector: extra selector, use it to save selected result
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenE(self, limit, value, colIndex = 0, extraSelector = None):
        dst = extraSelector
        if (dst == None):
            dst = []
        # 1.check indexed set
        if (limit == 1):
            if (colIndex in self._indexSet):
                m = self._indexSet[colIndex]
                if (value in m):
                    val = m[value]
                    if (val):
                        dst.append(val)
                    self._selector = dst
                    return self
        # 2.line-by-line scan
        src = self._selector
        if (src == None):
            src = self.body
        for row in src:
            if (row[colIndex] == value):
                dst.append(row)
                limit = limit - 1
                if (limit == 0):
                    break
        self._selector = dst
        return self
    '''
    Select the rows when the column's values are equal to specified values.

    :param limit: maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param value1: first specified value
    :param value2: second specified value
    :param colIndex2: second specified column index
    :param colIndex1: first specified column index
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenE2(self, limit, value1, value2, colIndex2 = 1, colIndex1 = 0):
        src = self._selector
        if (src == None):
            src = self.body
        dst = []
        for row in src:
            if (row[colIndex1] == value1 and row[colIndex2] == value2):
                dst.append(row)
                limit = limit - 1
                if (limit == 0):
                    break
        self._selector = dst
        return self
    '''
    Select the rows when the column's values are equal to specified values.

    :param limit: maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param value1: first specified value
    :param value2: second specified value
    :param value3: third specified value
    :param colIndex3: third specified column index
    :param colIndex2; second specified column index
    :param colIndex1: first specified column index
    :return: Table THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenE3(self, limit, value1, value2, value3, colIndex3 = 2, colIndex2 = 1, colIndex1 = 0):
        src = self._selector
        if (src == None):
            src = self.body
        dst = []
        for row in src:
            if (row[colIndex1] == value1 and row[colIndex2] == value2 and row[colIndex3] == value3):
                dst.append(row)
                limit = limit - 1
                if (limit == 0):
                    break
        self._selector = dst
        return self
    '''
    Select the rows when the column's value is greater than specified value.

    :param limit: maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param withEqu: whether include equation
    :param value: the specified value
    :param colIndex: specified column index
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenG(self, limit, withEqu, value, colIndex = 0):
        src = self._selector
        if (src == None):
            src = self.body
        dst = []
        for row in src:
            rowVal = row[colIndex]
            if (rowVal > value or (withEqu and rowVal == value)):
                dst.append(row)
                limit = limit - 1
                if (limit == 0):
                    break
        self._selector = dst
        return self
    '''
    Select the rows when the column's value is less than specified values.

    :param limit: maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param withEqu: whether include equation
    :param value: the specified value
    :param colIndex: specified column index
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenL(self, limit, withEqu, value, colIndex = 0):
        src = self._selector
        if (src == None):
            src = self.body
        dst = []
        for row in src:
            rowVal = row[colIndex]
            if (rowVal < value or (withEqu and rowVal == value)):
                dst.append(row)
                limit = limit - 1
                if (limit == 0):
                    break
        self._selector = dst
        return self
    '''
    Select the rows when the column's value is greater than specified value <b>and</b> less than specified value.

    :param limit: maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param GWithEqu: whether greater and equal
    :param LWithEqu: whether less and equal
    :param GValue: the specified greater value
    :param LValue: the specified less value
    :param colIndex: specified column index
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenGreaterAndLess(self, limit, GWithEqu, LWithEqu, GValue, LValue, colIndex = 0):
        src = self._selector
        if (src == None):
            src = self.body
        dst = []
        for row in src:
            rowVal = row[colIndex]
            v1 = (rowVal > GValue or (GWithEqu and rowVal == GValue))
            v2 = (rowVal < LValue or (LWithEqu and rowVal == LValue))
            if (v1 and v2):
                dst.append(row)
                limit = limit - 1
                if (limit == 0):
                    break
        self._selector = dst
        return self
    '''
    Select the rows when the column's value is less than specified value <b>or</b> greater than specified value.

    :param limit: maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
    :param LWithEqu: whether less and equal
    :param GWithEqu: whether greater and equal
    :param LValue: the specified less value
    :param GValue: the specified greater value
    :param colIndex: specified column index
    :return: THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
    '''
    def selectWhenLessOrGreater(self, limit, LWithEqu, GWithEqu, LValue, GValue, colIndex = 0):
        src = self._selector
        if (src == None):
            src = self.body
        dst = []
        for row in src:
            rowVal = row[colIndex]
            v1 = (rowVal < LValue or (LWithEqu and rowVal == LValue))
            v2 = (rowVal > GValue or (GWithEqu and rowVal == GValue))
            if (v1 or v2):
                dst.append(row)
                limit = limit - 1
                if (limit == 0):
                    break
        self._selector = dst
        return self
    '''
    Parse csv conent.

    :param content: As name mean
    :param filedSeparator: filed separator
    :param filedMultiLineDelimiter: filed multi-line delimiter
    :return: a table instance
    '''
    @staticmethod
    def Parse(content, filedSeparator = ",", filedMultiLineDelimiter = "\""):
        table = Table.arrayToRows(Table.textToArray(content, filedSeparator, filedMultiLineDelimiter))
        table.content = content
        return table
    '''
    Convert text to array.
    '''
    @staticmethod
    def textToArray(text, FS = ",", FML = "\""):
        FMLs = FML + FML
        arr = []
        maxLen = len(text)
        ptr = text
        ptrPos = 0
        while (True):
            curLen = maxLen - ptrPos
            cellIndexA = 0
            cellIndexB = 0
            cells = []
            cell = None
            cc = None  # current character
            while (cellIndexB < curLen):
                cellIndexA = cellIndexB
                cc = ptr[ptrPos + cellIndexB]
                if (cc == "\n" or cc == "\r\n"): # line is over
                    cellIndexB += 1
                    break
                if (cc == "\r" and ptr[ptrPos + cellIndexB + 1] == "\n"): # line is over
                    cellIndexB += 2
                    break
                if (cc == FS): # is separator
                    cell = ""
                    nextPos = ptrPos + cellIndexB + 1
                    if (nextPos >= maxLen):
                        cc = "\n"; # fix the bug when the last cell is empty
                    else:
                        cc = ptr[nextPos]
                    if (cellIndexA == 0 or cc == FS or cc == "\n" or cc == "\r\n"): # is empty cell
                        cellIndexB += 1
                        cells.append("")
                    elif (cc == "\r" and ptr[ptrPos + cellIndexB + 2] == "\n"): # is empty cell
                        cellIndexB += 2
                        cells.append("")
                    else:
                        cellIndexB += 1
                elif (cc == FML): # is double quote
                    # pass DQ
                    cellIndexB = cellIndexB + 1
                    # 1.find the nearest double quote
                    while (True):
                        cellIndexB = ptr.find(FML, ptrPos + cellIndexB)
                        if (cellIndexB == -1):
                            echo("[ACsv] Invalid Double Quote")
                            return None
                        cellIndexB -= ptrPos
                        if (ptr[ptrPos + cellIndexB + 1] == FML): # """" is normal double quote
                            cellIndexB += 2; # pass """"
                            continue
                        break
                    # 2.truncate the content of double quote
                    cell = ptr[ptrPos + cellIndexA + 1 : ptrPos + cellIndexB]
                    cell = cell.replace(FMLs, FML); # convert """" to ""
                    cells.append(cell)
                    # pass DQ
                    cellIndexB = cellIndexB + 1
                else: # is normal
                    # 1.find the nearest comma and LF
                    indexA = ptr.find(FS, ptrPos + cellIndexB)
                    if (indexA == -1):
                        indexA = curLen; # is last cell
                    else:
                        indexA -= ptrPos
                    indexB = ptr.find("\r\n", ptrPos + cellIndexB)
                    if (indexB == -1):
                        indexB = ptr.find("\n", ptrPos + cellIndexB)
                        if (indexB == -1):
                            indexB = curLen
                        else:
                            indexB -= ptrPos
                    else:
                        indexB -= ptrPos
                    cellIndexB = indexA
                    if (indexB < indexA): # row is end
                        cellIndexB = indexB
                    # 2.Truncate the cell contennt
                    cell = ptr[ptrPos + cellIndexA : ptrPos + cellIndexB]
                    cells.append(cell)
            arr.append(cells)
            # move to next position
            ptrPos += cellIndexB
            if (ptrPos >= maxLen):
                break
        return arr
    '''
    Convert array to rows.
    '''
    @staticmethod
    def arrayToRows(arr):
        rawHead = arr[0]
        srcBody = arr[1:]
        # parse head
        newHead = []
        for fullName in rawHead:
            parts = fullName.split(':')
            filed = Field()
            filed.fullName = fullName
            filed.name = parts[0]
            filed.type = ''
            if len(parts) == 2:
                filed.type = parts[1]
            newHead.append(filed)
        # parse body
        for i, row in enumerate(srcBody):
            for j, cell in enumerate(row):
                newVal = cell
                ft = newHead[j].type
                isEmptyCell = (cell == None or cell == '')
                if (ft == 'bool'):
                    if (isEmptyCell or cell == 'false' or cell == '0'):
                        newVal = False
                    else:
                        newVal = True
                elif (ft == 'int'):
                    if (isEmptyCell):
                        newVal = 0
                    else:
                        newVal = int(cell)
                elif (ft == 'number'):
                    if (isEmptyCell):
                        newVal = 0.0
                    else:
                        newVal = float(cell)
                elif (ft == 'json'):
                    if (isEmptyCell):
                        newVal = None
                    else:
                        cc = cell[0]
                        if (not (cc == '[' or cc == '{')):
                            echo("[ACsv] Invalid json format:" + newHead[j].name + ',' + cell)
                            return None
                        newVal = cell
                elif (ft == 'strings'):
                    if (isEmptyCell):
                        newVal = '[]'
                    else:
                        newVal = '["' + "\",\"".join(cell.split(',')) + '"]'
                row[j] = newVal
            srcBody[i] = row; # update row
        # create table
        table = Table()
        table.head = newHead
        table.body = srcBody
        return table
     
'''
Supported json field types.
'''
Table.JSON_TYPES = ["json", "strings"]
'''
1. Copyright (c) 2022 amin2312
2. Version 1.0.0
3. MIT License

CSV head field.

'''
class Field:
    '''
    Full Name.
    '''
    fullName = ''
    '''
    Name.
    '''
    name = ''
    '''
    Type.
    '''
    type = ''