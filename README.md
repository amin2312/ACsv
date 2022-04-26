ACsv Library
================
**ACsv** is a easy, fast and powerful csv parse library.  

The features:
* Standard - support standard csv format (RFC 4180)
* Tiny size - js version is only 6k
* Easy to use - provide the example, demo and documentation
* Fast speed - optimized code for high performance, it can works easy in older devices
* Powerful - support enhanced csv format, you can declare the field type after field name ⭐(<b>like width<u>:int</u>, name<u>:string</u></b>), please see details from "release/csvs/enhanced_format_text.csv"  
	> \* current supported field types: bool, int, number, json, strings
* Cross platform - provide js, lua, python version 
  

Example
----------------
```javascript
var table = acsv.Table.Parse(csv_content);
table.selectWhenE(1, 1).toObj();
table.selectWhenE2(1, 21, 2).toObjs();
// Method Chaining Usage - multi filter selected data
table.selectWhenE(0, 100, 2).selectWhenL(0, false, 22, 1).toObjs();
```

Demos 
----------------
* [Javascript demo - via Haxe code to compile](https://amin2312.github.io/ACsv/release/demos/demo.hx.html)
* [Javascript demo - via Typescript code with library to compile](https://amin2312.github.io/ACsv/release/demos/demo.ts.html)

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
