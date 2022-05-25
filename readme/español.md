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
  
**ACsv** es una  **csv parsing librería** fácil, multi-plataforma y poderosa.  

Las características:
* **multi-plataforma** - proveer **haxe**, **js**, **ts**, **php**, **java**, **python**, **c#** , **golang** versión
* **estándar** - compatible con csv estándar formato (RFC 4180)
* **fácil de usar** - proporcione el ejemplo, la demostración y la documentación
* **rápida velocidad** - código optimizado para alto rendimiento, puede funcionar fácilmente en dispositivos más antiguos
* **poderoso** - apoyar **mejorada** csv formato,  
&emsp;&emsp;&emsp;&emsp;&emsp;ver detalles en [pagina en ingles](../README.md)
  
ejemplo
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

demostración 
----------------
* [Javascript demo - via Haxe code to compile](https://amin2312.github.io/ACsv/release/js/demo.html)
* [Javascript demo - via Typescript code to compile](https://amin2312.github.io/ACsv/release/ts/demo.html)

documentación
----------------
[Online docs - via dox](https://amin2312.github.io/ACsv/release/docs/hx/index.html)

otros
----------------
***⭐ Si te gusta este proyecto, por favor dale una estrella***  
***⭐ [english version](../README.md)***  