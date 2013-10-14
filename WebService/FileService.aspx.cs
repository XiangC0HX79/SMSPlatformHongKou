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

public partial class FileService : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        String ID = Request.Params["id"];

        String index = Request.Params["index"];
        String textName = "txt" + index + ".txt";

        System.Drawing.Bitmap bitmap = new System.Drawing.Bitmap(Request.InputStream);

        Service sc = new Service();
        sc.SaveMMSImage(ID, index, "5", "jpg", bitmap);

        //String path = Server.MapPath(uploadFolder) + "\\F" + ID;

        //XmlDocument xmlDoc = new XmlDocument();
        //xmlDoc.Load(path + "\\mms.smil");

        ////String dur = Request.Params["dur"];
        //XmlNode parNode = xmlDoc.GetElementsByTagName("par")[Convert.ToInt16(index)];

        //if (Request.InputStream.Length != 0)
        //{
        //    String imgPre = Request.Params["imgName"].Split('.')[1];

        //    String imgName = "img" + index + "." + imgPre;

        //    System.Drawing.Bitmap image = new System.Drawing.Bitmap(Request.InputStream);
        //    image.Save(path + "\\" + imgName);

        //    XmlElement imgNode = xmlDoc.CreateElement("img", xmlDoc.DocumentElement.NamespaceURI); ;
        //    imgNode.SetAttribute("src", imgName);
        //    imgNode.SetAttribute("region", "img_region");

        //    parNode.AppendChild(imgNode);
        //}

        //XmlTextWriter writer = new XmlTextWriter(path + "\\mms.smil", Encoding.UTF8);
        //xmlDoc.WriteTo(writer);
        //writer.Close();
    }
}