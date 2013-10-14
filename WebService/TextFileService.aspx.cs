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

public partial class TextFileService : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        //string uploadFolder = "MMS"; // 上传文件夹

        String ID = Request.Params["id"];
        String index = Request.Params["index"];
        String dur = Request.Params["dur"];

        Byte[] byts = new byte[Request.InputStream.Length];
        Request.InputStream.Read(byts, 0, byts.Length);
        String text = Uri.UnescapeDataString(System.Text.Encoding.Default.GetString(byts));

        Service sc = new Service();
        sc.SaveMMSText(ID, index, dur, text);
    }
}