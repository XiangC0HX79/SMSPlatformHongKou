using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Update : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            var ps = System.Diagnostics.Process.GetProcesses();
            foreach (System.Diagnostics.Process thisProc in ps)
            {
                if ((thisProc.ProcessName.ToLower() == "SocketAsyncServer".ToLower())
                    ||
                    (thisProc.ProcessName.ToLower() == "irsetup".ToLower()))
                {
                    thisProc.Kill();
                }
            }

            var path = string.Format(@"{0}\Update.exe", Server.MapPath("App_Data"));

            var byteArr = new Byte[Request.InputStream.Length];

            if (byteArr.Length > 0)
            {
                Request.InputStream.Read(byteArr, 0, byteArr.Length);

                var file = new FileStream(path, FileMode.Create);

                file.Write(byteArr, 0, byteArr.Length);
                file.Flush();
                file.Close();
                               
                Process.Start(path, "");

                Response.Write("000");
            }
            else
            {
                Response.Write("更新文件长度为0。");
            }
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }

        Response.End();
    }
}
