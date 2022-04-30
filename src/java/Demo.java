import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.HashMap;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import acsv.*;

public class Demo
{
    /**
     * Tables
     */
    private static Table _tab1;
    private static Table _tab2;
    /**
     * Main Entry.
     * @return 
     */
    public static void main(String[] args)
    {
        System.out.println("Default charset=" + Charset.defaultCharset());
        System.out.println(System.getProperty("user.dir"));
        System.out.println();

        String standard_format_text = readToString("release/csvs/standard_format_text.csv");
		_tab1 = Table.Parse(standard_format_text);
        test_standard_csv_format();
        String enhanced_format_text = readToString("release/csvs/enhanced_format_text.csv");
		_tab2 = Table.Parse(enhanced_format_text);
        try {
            test_enhanced_csv_format();
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
    
    public static void P(String cmd, Object o)
    {
        System.out.println(cmd);
        if (o == null)
        {
            System.out.println("null");
        }
        else if (o instanceof HashMap)
        {
            System.out.println(o);
        }
        else if (o instanceof Object[])
        {
            System.out.println(Arrays.deepToString((Object[]) o));
        }
        else
        {
            System.out.println(o);
        }
        System.out.println();
    }

	public static void test_standard_csv_format()
    {
		P("select ALL to rows", _tab1.selectAll().toRows());
		P("select ALL to objs", _tab1.selectAll().toObjs());
		P("select first row", _tab1.selectFirstRow().toFirstRow());
        P("select first obj", _tab1.selectFirstRow().toFirstObj());
		P("select last row", _tab1.selectLastRow().toFirstRow());
        P("select last obj", _tab1.selectLastRow().toFirstObj());

		P("selectWhenE (id) = \"2\"", _tab1.selectWhenE(1, "2", 0, null).toFirstObj());
		P("selectWhenE (id) = \"3\" and (id2) = \"21\"", _tab1.selectWhenE2(1, "3", "21", 1, 0).toFirstObj());
		P("selectWhenE (id) = \"4\" and (id2) = \"21\" and (id3) = \"200\"", _tab1.selectWhenE3(1, "4", "21", "200", 2, 1, 0).toFirstObj());
		P("selectWhenE ALL (id2) = \"20\"", _tab1.selectWhenE(0, "20", 1, null).toObjs());
        P("merge tables", _tab1.merge(_tab1).selectAll().toRows());
	}

	public static void test_enhanced_csv_format() throws JSONException
    {
		P("[E] select ALL to rows", _tab2.selectAll().toRows());
		P("[E] select ALL to objs", _tab2.selectAll().toObjs());
		P("[E] select first row", _tab2.selectFirstRow().toFirstRow());
        P("[E] select first obj", _tab2.selectFirstRow().toFirstObj());
		P("[E] select last row", _tab2.selectLastRow().toFirstRow());
        P("[E] select last obj", _tab2.selectLastRow().toFirstObj());

		P("[E] selectWhenE (id) = 2", _tab2.selectWhenE(1, 2, 0, null).toFirstObj());
		P("[E] selectWhenE (id) = -1", _tab2.selectWhenE(1, -1, 0, null).toFirstObj());
		P("[E] selectWhenE2 (id) = 3 and (id2) = 22", _tab2.selectWhenE2(1, 3, 22, 1, 0).toFirstObj());
		P("[E] selectWhenE2 (id) = 3 and (id2) = -1", _tab2.selectWhenE2(1, 3, -1,1,0).toFirstObj());
		P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = 200", _tab2.selectWhenE3(1, 4, 22, 200, 2, 1, 0).toFirstObj());
		P("[E] selectWhenE3 (id) = 4 and (id2) = 22 and (id3) = -1", _tab2.selectWhenE3(1, 4, 22, -1, 2, 1, 0).toFirstObj());
		P("[E] selectWhenE ALL (id2) = 21", _tab2.selectWhenE(0, 21, 1, null).toObjs());
		P("[E] selectWhenE ALL (id2) = -1", _tab2.selectWhenE(0, -1, 1, null).toObjs());

		P("[E] selectWhenG ALL (id2) > 25", _tab2.selectWhenG(0, false, 25, 1).toObjs());
		P("[E] selectWhenG ALL (id2) >= 25", _tab2.selectWhenG(0, true, 25, 1).toObjs());
		P("[E] selectWhenG ALL (id2) > 30", _tab2.selectWhenG(0, false, 30, 1).toObjs());
		P("[E] selectWhenL ALL (id2) < 22", _tab2.selectWhenL(0, false, 22, 1).toObjs());
		P("[E] selectWhenL ALL (id2) <= 22", _tab2.selectWhenL(0, true, 22, 1).toObjs());
		P("[E] selectWhenL ALL (id2) < 20", _tab2.selectWhenL(0, true, 20, 1).toObjs());
        P("[E] selectWhenGreaterAndLess ALL (id2) > 21 and (id2) < 24", _tab2.selectWhenGreaterAndLess(0, false, false, 21, 24, 1).toObjs());
        P("[E] selectWhenGreaterAndLess ALL (id2) >= 21 and (id2) <= 24", _tab2.selectWhenGreaterAndLess(0, true, true, 21, 24, 1).toObjs());
        P("[E] selectWhenLessOrGreater ALL (id2) < 22 or (id2) > 25", _tab2.selectWhenLessOrGreater(0, false, false, 22, 25, 1).toObjs());
        P("[E] selectWhenLessOrGreater ALL (id2) <= 22 or (id2) >= 25", _tab2.selectWhenLessOrGreater(0, true, true, 22, 25, 1).toObjs());
		P("[E] selectWhenIn (id) in 3,4,5", _tab2.selectWhenIn(1, new Object[]{3,4,5},0).toObjs());
		P("[E] selectAt rows at 0,1,10", _tab2.selectAt(new int[]{0,1,10}).toObjs());

		P("[E] multi selects (id3) = 100 and (id2) < 22", _tab2.selectWhenE(0, 100, 2, null).selectWhenL(0, false, 22, 1).toObjs());
        P("[E] sort by (id3) = 300 desc (id)", _tab2.selectWhenE(0, 300, 2, null).sortBy(0, 1).toObjs());

        _tab2.createIndexAt(0);
		P("[E] (indexed) 1st row name", _tab2.selectWhenE(1, "Dwi", _tab2.getColIndexBy("name"), null).toObjs()[0].get("name"));
        P("[E] (indexed) id=6 education.CC", ((JSONObject)_tab2.id(6, 0).get("education")).getString("CC") );
        P("[E] (indexed) id=6 tags #2", ((JSONArray)_tab2.id(6, 0).get("tags")).get(1) );
		P("[E] (indexed) 99th row", _tab2.selectWhenE(1, 99, 0, null).toObjs());
	}
    
    public static String readToString(String fileName) 
    {
        String encoding = "UTF-8";
        File file = new File(fileName);
        Long filelength = file.length();
        byte[] filecontent = new byte[filelength.intValue()];
        try 
        {
            FileInputStream in = new FileInputStream(file);
            in.read(filecontent);
            in.close();
        } 
        catch (FileNotFoundException e) 
        {
            e.printStackTrace();
        } catch (IOException e) 
        {
            e.printStackTrace();
        }
        try 
        {
            return new String(filecontent, encoding);
        } 
        catch (UnsupportedEncodingException e) 
        {
            System.err.println("The OS does not support " + encoding);
            e.printStackTrace();
            return null;
        }
    }
}