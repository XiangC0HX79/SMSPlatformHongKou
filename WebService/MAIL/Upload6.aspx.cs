using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using System.IO;
using System.Text;
using System.Xml;

public partial class Upload6 : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            String fileName = HttpUtility.UrlDecode(Request.Params["fileName"]); ;
            String pageLen = HttpUtility.UrlDecode(Request.Params["pageLen"]);
            String pageIndex = HttpUtility.UrlDecode(Request.Params["pageIndex"]);

            if (Request.InputStream.Length != Convert.ToInt64(pageLen))
            {
                Response.Write("数据包大小错误");
                Response.End();
            }
            else
            {
                String path = Server.MapPath("");

                Byte[] byteArr = new Byte[Request.InputStream.Length];
                Request.InputStream.Read(byteArr, 0, byteArr.Length);

                if (!Directory.Exists(path))
                {
                    Directory.CreateDirectory(path);
                }

                FileStream file;
                if (Convert.ToInt32(pageIndex) == 0)
                    file = new FileStream(path + "\\" + fileName, FileMode.Create);
                else
                    file = new FileStream(path + "\\" + fileName, FileMode.Append);

                file.Write(byteArr, 0, byteArr.Length);
                file.Flush();
                file.Close();

                var fileInfo = new FileInfo(path + "\\" + fileName);

                Response.Write(fileInfo.Length);
            }
        }
        catch (Exception ex)
        {
            Response.Write(ex.Message);
        }

        Response.End();
    }
}