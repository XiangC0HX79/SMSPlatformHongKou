using System;

namespace Update
{
    class Program
    {
        static void Main(string[] args)
        {
            String conStr = "Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source="
                     + @"D:\dkqn-huangxiang-smsplatform\webService\App_Data\Data.mdb"
                     + ";Extended Properties=";
            try
            {
                var clsGetData = new ClsGetData("System.Data.OleDb", conStr);

                var sql = "ALTER TABLE 短信_发件箱 ADD 发送号码 CHAR(20)";

                clsGetData.SetTable(sql);
            }
            catch (Exception)
            {
                throw;
            }
        }
    }
}
