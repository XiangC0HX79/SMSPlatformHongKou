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

public partial class MailService : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        string uploadFolder = "MAIL"; // 上传文件夹

        String path = Server.MapPath(uploadFolder);

        HttpFileCollection files = Request.Files;

        if (files.Count == 0)
        {
            Response.Write("请勿直接访问本文件");
            Response.End();
        }

        // 只取第 1 个文件
        HttpPostedFile file = files[0];

        if (file != null && file.ContentLength > 0)
        {
            // flash 会自动发送文件名到 Request.Form["fileName"]
            string savePath = path + "/" + Request.Form["fileName"];
            file.SaveAs(savePath);
        }
    }
}