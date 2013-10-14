using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace csharpEmppApiTest
{
    class LogUtil
    {

        static String fileName = "LogFile.txt";
        static StreamWriter sw = null;
        static StreamReader sr = null;
        static char[] ch;
        private static bool isUse = true;

        private static void init(){
             if (File.Exists(fileName)){
                Console.WriteLine("we into the exist");
                sr = new StreamReader(fileName);
                int length = (int)sr.BaseStream.Length;
                ch = new char[length];
                sr.ReadBlock(ch, 0, length);
                sr.Close();
                sw = new StreamWriter(fileName);
                sw.Write(new String(ch));
                
                Console.Write(new String(ch));
            }else{
                Console.WriteLine("we into the not exist,an we will create the file :" + fileName);
                sw = new StreamWriter(fileName);
            }           
        }
        

        public static void toLog(String  log) {
            if(isUse){
                init();
                isUse = false;
            }
            sw.WriteLine(DateTime.Now.ToString() +" " +  log);
            sw.Flush();
        }

    }
}
