ACsv Library
================
[![](https://img.shields.io/badge/support-haxe-blue)](https://github.com/amin2312/ACsv/tree/main/src/haxe) 
[![](https://img.shields.io/badge/support-javascript-blue)](https://github.com/amin2312/ACsv/tree/main/src/javascript) 
[![](https://img.shields.io/badge/support-typescript-blue)](https://github.com/amin2312/ACsv/tree/main/src/typescript) 
[![](https://img.shields.io/badge/support-php-blue)](https://github.com/amin2312/ACsv/tree/main/src/php) 
[![](https://img.shields.io/badge/support-java-blue)](https://github.com/amin2312/ACsv/tree/main/src/java) 
[![](https://img.shields.io/badge/support-python-blue)](https://github.com/amin2312/ACsv/tree/main/src/python)  
[![](https://img.shields.io/badge/csv-parse-green)](https://github.com/amin2312/ACsv/tree/main/src/python) 
[![](https://img.shields.io/badge/csv-standard-green)](https://github.com/amin2312/ACsv/tree/main/src/python) 
[![](https://img.shields.io/badge/csv-enhanced-green)](https://github.com/amin2312/ACsv/tree/main/src/python)  
  
**ACsv** is a easy, fast and powerful **csv parse** library.  

The features:
* **Cross platform** - provide **haxe**, **js**, **ts**, **php**, **java**, **python** version (the lua version via Haxe)
* **Standard** - support standard csv format (RFC 4180)
* **Tiny size** - js version is only 7k
* **Easy to use** - provide the example, demo and documentation
* **Fast speed** - optimized code for high performance, it can works easy in older device
* **Powerful** - support **enhanced** csv format,  
&emsp;&emsp;&emsp;&emsp;&emsp;allow field type to be declared after field name (like width:**int**, name:**string**),  
&emsp;&emsp;&emsp;&emsp;&emsp;supported field types: **bool, int, number, string, json, strings**  
&emsp;&emsp;&emsp;&emsp;&emsp;see details in "release/csvs/enhanced_format_text.csv"   
  
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
***⭐ If you like this project, please give a star ⭐***
+ **español**  
"ACsv" es una biblioteca de análisis CSV fácil, pequeña y potente.  
Se está ejecutando en un sistema comercial.  
Es estable y se puede utilizar con confianza.
+ **portugués**  
"ACsv" é uma biblioteca de análise de CSV fácil, pequena e poderosa.  
Ele está sendo executado em um sistema comercial.  
É estável e pode ser usado com confiança.
+ **Deutsch**  
"ACsv" ist eine einfache, winzige und leistungsstarke CSV-Parsing-Bibliothek.  
Es läuft in einem kommerziellen System.  
Es ist stabil und kann mit Zuversicht verwendet werden.
+ **français**  
"ACsv" est une bibliothèque d'analyse CSV simple, petite et puissante.  
Il fonctionne dans un système commercial.  
Il est stable et peut être utilisé en toute confiance.
+ **italiano**  
"ACsv" è una libreria di analisi CSV semplice, piccola e potente.  
È in esecuzione in un sistema commerciale.  
È stabile e può essere utilizzato con sicurezza.
+ **Türkçe**  
"ACsv" kolay, küçük ve güçlü bir CSV ayrıştırma kitaplığıdır.  
Ticari bir sistemde çalışıyor.  
Stabildir ve güvenle kullanılabilir.
+ **русский**  
"ACsv" — это простая, компактная и мощная библиотека для разбора CSV.  
Он работает в коммерческой системе.  
Он стабилен и может использоваться с уверенностью.
+ **中文**  
"ACsv"是一个简单、小巧且功能强大的 CSV 解析库。   
它正在商业系统中运行。  
它很稳定，可以放心使用。
+ **日本語**  
"ACsv"は、簡単で小さくて強力なCSV解析ライブラリです。  
商用システムで実行されています。  
安定していて安心してお使いいただけます。
+ **tiếng Việt**  
"ACsv" là một thư viện phân tích cú pháp CSV dễ dàng, nhỏ và mạnh mẽ.  
Nó đang chạy trong một hệ thống thương mại.  
Nó ổn định và có thể được sử dụng một cách tự tin.
+ **Indonesia**  
"ACsv" adalah library penguraian CSV yang mudah, kecil, dan kuat.  
Itu berjalan dalam sistem komersial.  
Ini stabil dan dapat digunakan dengan percaya diri.
