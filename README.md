ACsv Library
================
[![](https://img.shields.io/badge/support-haxe-blue)](https://github.com/amin2312/ACsv/tree/main/src/haxe) 
[![](https://img.shields.io/badge/support-javascript-blue)](https://github.com/amin2312/ACsv/tree/main/src/javascript) 
[![](https://img.shields.io/badge/support-typescript-blue)](https://github.com/amin2312/ACsv/tree/main/src/typescript) 
[![](https://img.shields.io/badge/support-php-blue)](https://github.com/amin2312/ACsv/tree/main/src/php) 
[![](https://img.shields.io/badge/support-java-blue)](https://github.com/amin2312/ACsv/tree/main/src/java) 
[![](https://img.shields.io/badge/support-python-blue)](https://github.com/amin2312/ACsv/tree/main/src/python) 
[![](https://img.shields.io/badge/support-c%23-blue)](https://github.com/amin2312/ACsv/tree/main/src/csharp)
[![](https://img.shields.io/badge/support-golang-blue)](https://github.com/amin2312/ACsv/tree/main/src/csharp)  
[![](https://img.shields.io/badge/csv-parsing-green)](https://github.com/amin2312/ACsv/tree/main/src/python) 
[![](https://img.shields.io/badge/csv-standard-green)](https://github.com/amin2312/ACsv/tree/main/src/python) 
[![](https://img.shields.io/badge/csv-enhanced-red)](https://github.com/amin2312/ACsv/tree/main/src/python)  
  
| **[Español](languages/espa%C3%B1ol.md)** | **[Portugués](languages/portugués.md)** | **[Français](languages/fran%C3%A7ais.md)** | **[Русский](languages/русский.md)** | **[中文](languages/中文.md)** | **[日本語](languages/日本語.md)** | **[Tiếng Việt](languages/tiếng_việt.md)** | **[Indonesia](languages/indonesia.md)** |  
  
**ACsv** is an easy, multi-platform and powerful **"csv parsing library"**.  
The features:
* **Multi-platform** - provides **Haxe**, **JS**, **TS**, **PHP**, **Java**, **Python**, **C#**, and **Golang** versions
* **Standard** - supports standard CSV format (RFC 4180)
* **Easy to use** - provides example, demos and documentations
* **Fast speed** - optimized code for high performance. It can work easily in older devices.
* **Powerful** - supports **enhanced** CSV format;  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;allows field type to be declared after the field name (like [![](https://img.shields.io/badge/name-:string-blue)]());  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;supported field types: **bool, int, number, string, json, strings**;  
&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;See details in "release/csvs/enhanced_format_text.csv"  
&emsp;&emsp;&emsp;&emsp;&nbsp;&nbsp;- compatibles with unicdoe BOM
  
Example
----------------
```javascript
// enhanced_csv_content
//----------------------------------------------------------------
//| id:int | name:string | age:int | weight:number | tags:json   |
//|--------------------------------------------------------------|
//|    1   |   John      |   20    | 60.1          | ["cool"]    |
//|    2   |   Mary      |   20    | 60.2          | ["thin"]    |
//|    3   |   Tom       |   18    | 60.3          | ["young"]   |
//----------------------------------------------------------------

var table = acsv.Table.Parse(enhanced_csv_content);
table.selectWhenE(1, 3).toFirstObj();
// {id: 3, name: "Tom",  age: 18, weight: 60.3, tags: ["young"] }

table.selectWhenE(0, 20, 2).toObjs();
// [ 
//   {id: 1, name: "John", age: 20, weight: 60.1, tags: ["cool"] }, 
//   {id: 2, name: "Mary", age: 20, weight: 60.2, tags: ["thin"] }
// ]

// Method Chaining Usage
table.selectWhenE(0, 20, 2).selectWhenL(0, false, 60.2).toObjs();
// [ 
//   {id: 1, name: "John",  age: 20, weight: 60.1, tags: ["cool"] }
// ]
```

Demos 
----------------
* [Javascript demo - via Haxe code to compile](https://amin2312.github.io/ACsv/release/js/demo.html)
* [Javascript demo - via Typescript code to compile](https://amin2312.github.io/ACsv/release/ts/demo.html)

Docs
----------------
[Online docs - via dox](https://amin2312.github.io/ACsv/release/docs/hx/index.html)

Others
----------------
***⭐ If you like this project, please add a star ⭐***