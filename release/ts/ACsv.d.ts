declare namespace acsv
{
    class Field
    {
        /**
         * Full Name.
         */
        fullName: string;
        /**
         * Name.
         */
        name: string;
        /**
         * Type.
         */
        type: string;
    }
    class Table
    {
        /**
         * The raw content.
         */
        content: number;
        /**
         * Parsed csv table Head.
         */
        head: Array<Field>;
        /**
         * Parsed csv table Body.
         */
        body: Array<Array<any>>;
        /**
         * Parse csv conent.
         */
        static Parse(content: String): Table
        /**
         * Merge a table.
         * <br/><b>Notice:</b> two tables' structure must be same.
         * @param b source table
         */
        merge(b: Table);
        /**
         * Create index for the specified column.
         * <br>This function is only valid for "selectWhenE" and "limit" param is 1.
         * <br>It will improve performance.
         * @param colIndex column index
         */
        createIndexAt(colIndex: number): void;
        /**
         * Get column index by specified field name.
         * @param name As name mean.
         */
        getColIndexBy(name: String): number;
        /**
         * Sort by selected rows.
         * @param colIndex specified column's index
         * @param sortType 0: asc, 1: desc
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        sortBy(colIndex: number, sortType: number): Table
        /**
         * Get current selector(it includes all selected results).
         <br>It be assigned after call "select..." function
         */
        getCurrentSelector(): Array<any>;
        /**
         * Format data to row.
         */
        fmtRow(row: Array<any>): Array<any>;
        /**
         * Format data to obj.
         */
        fmtObj(row: Array<any>): any;
        /**
         * Fetch first selected result to a row and return it.
         */
        toFirstRow(): Array<any>;
        /**
         * Fetch last selected result to a row and return it.
         */
        toLastRow(): Array<any>
        /**
         * Fetch all selected results to the rows and return it.
         */
        toRows(): Array<Array<any>>
        /**
         * Fetch first selected result to a object and return it.
         */
        toFirstObj(): any
        /**
         * Fetch last selected result to a object and return it.
         */
        toLastObj(): any
        /**
         * Fetch all selected results to the objects and return it.
         */
        toObjs(): Array<any>
        /**
         * Select all rows.
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectAll(): Table
        /**
         * Select the first row.
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectFirstRow(): Table
        /**
         * Select the last row.
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectLastRow(): Table
         /**
         * Selects the specified <b>rows</b> by indices.
         * @param rowIndices specified row's indices
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        selectAt(rowIndices:Array<number>):Table
        /**
         * Select the rows when the column's value is equal to any value of array.
         * @param limit maximum length of every selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param values the specified values of array
         * @param colIndex specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." or "select..." function in next step.
         */
        selectWhenIn(limit: number, values: Array<any>, colIndex?: number): Table
        /**
         * Select the rows when the column's value is equal to specified value.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param value the specified value
         * @param colIndex specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectWhenE(limit: number, value: any, colIndex?: number): Table
        /**
         * Select the rows when the column's values are equal to specified values.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param value1 first specified value
         * @param value2 second specified value
         * @param colIndex2 second specified column's index
         * @param colIndex1 first specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectWhenE2(limit: number, value1: any, value2: any, colIndex2?: number, colIndex1?: number): Table
        /**
         * Select the rows when the column's values are equal to specified values.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param value1 first specified value
         * @param value2 second specified value
         * @param value3 third specified value
         * @param colIndex3 third specified column's index
         * @param colIndex2 second specified column's index
         * @param colIndex1 first specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectWhenE3(limit: number, value1: any, value2: any, value3: any, colIndex3?: number, colIndex2?: number, colIndex1?: number): Table
        /**
         * Select the rows when the column's value is greater than specified value.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param withEqu whether include equation
         * @param value the specified value
         * @param colIndex specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectWhenG(limit: number, withEqu: boolean, value: number, colIndex?: number): Table
        /**
         * Select the rows when the column's value is less than specified values.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param withEqu whether include equation
         * @param value the specified value
         * @param colIndex specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectWhenL(limit: number, withEqu: boolean, value: number, colIndex?: number): Table
        /**
         * Select the rows when the column's value is greater than specified value <b>and</b> less than specified value.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param GWithEqu whether greater and equal
         * @param LWithEqu whether less and equal
         * @param GValue the specified greater value
         * @param LValue the specified less value
         * @param colIndex specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectWhenGreaterAndLess(limit: number, GWithEqu: boolean, LWithEqu: boolean, GValue: number, LValue: number, colIndex?: number): Table
        /**
         * Select the rows when the column's value is less than specified value <b>or</b> greater than specified value.
         * @param limit maximum length of selected results (0 is infinite, if you only need 1 result, 1 is recommended, it will improve performance)
         * @param LWithEqu whether less and equal
         * @param GWithEqu whether greater and equal
         * @param LValue the specified less value
         * @param GValue the specified greater value
         * @param colIndex specified column's index
         * @return THIS instance (for Method Chaining), can call "to..." function to get result in next step.
         */
        selectWhenLessOrGreater(limit: number, LWithEqu: boolean, GWithEqu: boolean, LValue: number, GValue: number, colIndex?: number): Table
    }
}