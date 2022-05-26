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
  
**ACsv** là một **"csv parsing library"** dễ dàng, đa nền tảng và mạnh mẽ.  

Các tính năng:
* **đa nền tảng** - cung cấp **haxe**, **js**, **ts**, **php**, **java**, **python**, **c#** , **golang** phiên bản
* **tiêu chuẩn** - hỗ trợ csv tiêu chuẩn định dạng (RFC 4180)
* **dễ sử dụng** - cung cấp ví dụ, bản trình diễn và tài liệu
* **tốc độ nhanh** - mã được tối ưu hóa cho hiệu suất cao, nó có thể hoạt động dễ dàng trong thiết bị cũ hơn
* **mạnh mẽ** - hỗ trợ **"enhanced"** csv định dạng, xem chi tiết trong [trang Engilsh](../README.md)  
  
ví dụ
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

bản trình diễn 
----------------
* [Javascript demo - via Haxe code to compile](https://amin2312.github.io/ACsv/release/js/demo.html)
* [Javascript demo - via Typescript code to compile](https://amin2312.github.io/ACsv/release/ts/demo.html)

tài liệu
----------------
[Online docs - via dox](https://amin2312.github.io/ACsv/release/docs/hx/index.html)

khác
----------------
***⭐ Nếu bạn thích dự án này, hãy thêm một ngôi sao***  
***⭐ [english version](../README.md)***  