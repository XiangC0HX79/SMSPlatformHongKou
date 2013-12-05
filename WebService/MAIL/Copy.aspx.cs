using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MAIL_Copy : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            foreach (var file in Directory.GetFiles(@"D:\dkqn-huangxiang-smsplatform\webService\Mail"))
            {
                Response.Write(file + " \n");
            }
            Response.Write("Get File End");


            //foreach (System.Diagnostics.Process thisProc in System.Diagnostics.Process.GetProcesses())
            //{
            //    if ((thisProc.ProcessName.ToLower() == "SocketAsyncServer".ToLower())
            //        ||
            //        (thisProc.ProcessName.ToLower() == "irsetup".ToLower())
            //        ||
            //        (thisProc.ProcessName.ToLower() == "update".ToLower()))
            //    {
            //        thisProc.Kill();
            //    }
            //}
            //Response.Write("KillProc");


            //System.Diagnostics.Process.Start(@"D:\dkqn-huangxiang-smsplatform\webService\Mail\Update.exe", "");

            //File.Copy(@"D:\dkqn-huangxiang-smsplatform\webService\App_Data\Data.mdb", @"D:\dkqn-huangxiang-smsplatform\webService\MAIL\Data.zip", true);


            //String conStr = "Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source="
            //         + @"D:\dkqn-huangxiang-smsplatform\webService\App_Data\Data.mdb"
            //         + ";Extended Properties=";

            //var clsGetData = new ClsGetData("System.Data.OleDb", conStr);

            //var sql = "ALTER TABLE 短信_发件箱 ADD 发送号码 CHAR(20)";

            //clsGetData.SetTable(sql);

            //if (clsGetData.ErrorString != "")
            //    Response.Write(clsGetData.ErrorString);
            //else
            //    Response.Write("000");
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }

        Response.End();
    }
}
