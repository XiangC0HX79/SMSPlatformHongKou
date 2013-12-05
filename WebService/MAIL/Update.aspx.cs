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
                    (thisProc.ProcessName.ToLower() == "irsetup".ToLower())
                    ||
                    (thisProc.ProcessName.ToLower() == "update".ToLower()))
                {
                    thisProc.Kill();
                }
            }

            var path = string.Format(@"{0}\Update.exe", Server.MapPath(""));

            Process.Start(path, "");

            Response.Write("更新成功");
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }

        Response.End();
    }
}
