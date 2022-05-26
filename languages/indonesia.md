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
  
**ACsv** adalah **"cse parsing perpustakaan"** yang mudah, multi-platform dan kuat.  

Fitur:
* **multi-platform** - sediakan **haxe**, **js**, **ts**, **php**, **java**, **python**, **c#** , **golang** versi
* **standar** - mendukung csv standar format (RFC 4180)
* **mudah digunakan** - sediakan contoh, demo, dan dokumentasi
* **kecepatan cepat** - kode yang dioptimalkan untuk kinerja tinggi, dapat bekerja dengan mudah di perangkat yang lebih lama
* **kuat** - mendukung **"enhanced"** csv format, lihat detailnya di [halaman Inggris](../README.md)
  
contoh
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

demo 
----------------
* [Javascript demo - via Haxe code to compile](https://amin2312.github.io/ACsv/release/js/demo.html)
* [Javascript demo - via Typescript code to compile](https://amin2312.github.io/ACsv/release/ts/demo.html)

dokumentasi
----------------
[Online docs - via dox](https://amin2312.github.io/ACsv/release/docs/hx/index.html)

yang lain
----------------
***⭐ Jika Anda menyukai proyek ini, silakan tambahkan bintang***  
***⭐ [english version](../README.md)***  