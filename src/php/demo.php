<?php
require "ACsv.php";
use acsv\Table as Table;
/**
 * Tables
 */
$_tab1;
$_tab2;
/**
 * Main Entry.
 */
function main()
{
    global $_tab1, $_tab2;
    $standard_format_text = file_get_contents(__DIR__ .'/../../release/csvs/standard_format_text.csv');
    $_tab1 = Table::Parse($standard_format_text);
    test_standard_csv_format();
    $enhanced_format_text = file_get_contents(__DIR__ .'/../../release/csvs/enhanced_format_text.csv');
    $_tab2 = Table::Parse($enhanced_format_text);
    test_enhanced_csv_format();
}
function P($cmd, $o)
{
    echo($cmd ."\n");
    echo(json_encode($o, JSON_UNESCAPED_UNICODE) ."\n\n");
}
function test_standard_csv_format()
{
    global $_tab1;
    P('select ALL to rows', $_tab1->selectAll()->toRows());
    P('select ALL to objs', $_tab1->selectAll()->toObjs());
    P('select first row', $_tab1->selectFirstRow()->toFirstRow());
    P('select first obj', $_tab1->selectFirstRow()->toFirstObj());
    P('select last row', $_tab1->selectLastRow()->toFirstRow());
    P('select last obj', $_tab1->selectLastRow()->toFirstObj());

    P('selectWhenE (id) = "2"', $_tab1->selectWhenE(1, "2")->toFirstObj());
    P('selectWhenE (id) = "3" and (id2) = "21"', $_tab1->selectWhenE2(1, "3", "21")->toFirstObj());
    P('selectWhenE (id) = "4" and (id2) = "21" and (id3) = "200"', $_tab1->selectWhenE3(1, "4", "21", "200")->toFirstObj());
    P('selectWhenE ALL (id2) = "20"', $_tab1->selectWhenE(0, "20", 1)->toObjs());
    P('merge tables', $_tab1->merge($_tab1)->selectAll()->toRows());
}
function test_enhanced_csv_format()
{
    global $_tab2;
    P('[E] select ALL to rows', $_tab2->selectAll()->toRows());
    P('[E] select ALL to objs', $_tab2->selectAll()->toObjs());
    P('[E] select first row', $_tab2->selectFirstRow()->toFirstRow());
    P('[E] select first obj', $_tab2->selectFirstRow()->toFirstObj());
    P('[E] select last row', $_tab2->selectLastRow()->toFirstRow());
    P('[E] select last obj', $_tab2->selectLastRow()->toFirstObj());

    P('[E] selectWhenE (id) = 2', $_tab2->selectWhenE(1, 2)->toFirstObj());
    P('[E] selectWhenE (id) = -1', $_tab2->selectWhenE(1, -1)->toFirstObj());
    P('[E] selectWhenE2 (id) = 3 and (id2) = 22', $_tab2->selectWhenE2(1, 3, 22)->toFirstObj());
    P('[E] selectWhenE2 (id) = 3 and (id2) = -1', $_tab2->selectWhenE2(1, 3, -1)->toFirstObj());
    P('[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = 200', $_tab2->selectWhenE3(1, 4, 22, 200)->toFirstObj());
    P('[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = -1', $_tab2->selectWhenE3(1, 4, 22, -1)->toFirstObj());
    P('[E] selectWhenE ALL (id2) = 21', $_tab2->selectWhenE(0, 21, 1)->toObjs());
    P('[E] selectWhenE ALL (id2) = -1', $_tab2->selectWhenE(0, -1, 1)->toObjs());

    P('[E] selectWhenG ALL (id2) > 25', $_tab2->selectWhenG(0, false, 25, 1)->toObjs());
    P('[E] selectWhenG ALL (id2) >= 25', $_tab2->selectWhenG(0, true, 25, 1)->toObjs());
    P('[E] selectWhenG ALL (id2) > 30', $_tab2->selectWhenG(0, false, 30, 1)->toObjs());
    P('[E] selectWhenL ALL (id2) < 22', $_tab2->selectWhenL(0, false, 22, 1)->toObjs());
    P('[E] selectWhenL ALL (id2) <= 22', $_tab2->selectWhenL(0, true, 22, 1)->toObjs());
    P('[E] selectWhenL ALL (id2) < 20', $_tab2->selectWhenL(0, true, 20, 1)->toObjs());
    P('[E] selectWhenGreaterAndLess ALL (id2) > 21 and (id2) < 24', $_tab2->selectWhenGreaterAndLess(0, false, false, 21, 24, 1)->toObjs());
    P('[E] selectWhenGreaterAndLess ALL (id2) >= 21 and (id2) <= 24', $_tab2->selectWhenGreaterAndLess(0, true, true, 21, 24, 1)->toObjs());
    P('[E] selectWhenLessOrGreater ALL (id2) < 22 or (id2) > 25', $_tab2->selectWhenLessOrGreater(0, false, false, 22, 25, 1)->toObjs());
    P('[E] selectWhenLessOrGreater ALL (id2) <= 22 or (id2) >= 25', $_tab2->selectWhenLessOrGreater(0, true, true, 22, 25, 1)->toObjs());
    P('[E] selectWhenIn (id) in 3,4,5', $_tab2->selectWhenIn(1, [3, 4, 5])->toObjs());
    P('[E] selectAt rows at 0,1,10', $_tab2->selectAt([0, 1, 10])->toObjs());

    P('[E] multi selects (id3) = 100 and (id2) < 22', $_tab2->selectWhenE(0, 100, 2)->selectWhenL(0, false, 22, 1)->toObjs());
    P('[E] sort by (id3) = 300 desc (id)', $_tab2->selectWhenE(0, 300, 2)->sortBy(0, 1)->toObjs());

    $_tab2->createIndexAt(0);
    P("[E] (indexed) 1st row name", $_tab2->selectWhenE(1, 'Dwi', $_tab2->getColIndexBy('name'))->toObjs()[0]['name']);
    P("[E] (indexed) id=6 education #2", $_tab2->id(6)['education']->CC);
    P("[E] (indexed) id=6 tags #2", $_tab2->id(6)['tags'][1]);
    P("[E] (indexed) 99th row", $_tab2->selectWhenE(1, 99)->toObjs());
}
main();
