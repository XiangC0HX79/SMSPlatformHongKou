using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.IO;
using System.Runtime.InteropServices;
using System.Xml;
using System.Text;

public partial class WordService : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        const int charWidth = 210;

        string uploadFolder = "MMS\\TEMP"; // 上传文件夹

        String path = Server.MapPath(uploadFolder);

        HttpFileCollection files = Request.Files;

        if (files.Count == 0)
        {
            Response.Write("请勿直接访问本文件");
            Response.End();
        }

        // 只取第 1 个文件
        HttpPostedFile file = files[0];
        if (file == null || file.ContentLength == 0)
        {
            Response.Write("请先上传文件文件");
            Response.End();
        }

        object oFileName = "";

        object osaveFileName = "";
        
        object oMissing = System.Reflection.Missing.Value;
        
        object oReadOnly = false;

        Word._Application oWord = null;

        Word.Document oDoc = null;
        try
        {
            String title = Request.Form["fileName"];
            title = title.Substring(0,title.IndexOf('.'));

            String nowTime = DateTime.Now.ToString("yyyyMMddHHmmss") + (new Random()).Next(1000).ToString("###");
            string savePath = path + "\\" + nowTime + ".doc";
            while (File.Exists(savePath))
            {
                nowTime = DateTime.Now.ToString("yyyyMMddHHmmss") + (new Random()).Next(1000).ToString("###");
                savePath = path + "\\" + nowTime + ".doc";
            }

            file.SaveAs(savePath);

            oFileName = savePath;
            osaveFileName = path + "\\" + nowTime + ".xml";

            oWord = new Word.Application();

            oWord.Visible = false;

            oDoc = oWord.Documents.Open(ref oFileName, ref oMissing,

              ref oReadOnly, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing,

              ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing);

            object osaveFileFormat = Word.WdSaveFormat.wdFormatXML;

            oDoc.SaveAs(ref osaveFileName, ref osaveFileFormat,

              ref oReadOnly, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing,

              ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing, ref oMissing);

            oDoc.Close(ref oMissing, ref oMissing, ref oMissing);
            Marshal.ReleaseComObject(oDoc);
            oDoc = null;

            oWord.Quit(ref oMissing, ref oMissing, ref oMissing);
            Marshal.FinalReleaseComObject(oWord);
            oWord = null;

            /*以html格式保存该word文档后，对图像文件进行处理*/
            Service sc = new Service();
            String mmsID = sc.SetMMS("", title, "", "");
            
            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.Load(osaveFileName.ToString());

            XmlNamespaceManager nsmgr = new XmlNamespaceManager(xmlDoc.NameTable);
            nsmgr.AddNamespace("w", "http://schemas.microsoft.com/office/word/2003/wordml");
            nsmgr.AddNamespace("v", "urn:schemas-microsoft-com:vml");
            nsmgr.AddNamespace("wx", "http://schemas.microsoft.com/office/word/2003/auxHint");

            XmlNodeList binDatas = xmlDoc.SelectNodes("//w:pict/w:binData", nsmgr);
            
            XmlNodeList paragraphs = xmlDoc.SelectNodes("//w:body/wx:sect/w:p", nsmgr);
            int index = 0;
            String text = "";
            for (int i = 0; i < paragraphs.Count; i++)
            {
                XmlNode paragraph = paragraphs[i];

                XmlNode wTab = paragraph.SelectSingleNode("w:pPr/w:listPr/wx:t", nsmgr);
                if ((wTab != null) && (wTab.Attributes["wx:wTabBefore"] != null))
                {
                    int wTabBefore = Convert.ToInt32(wTab.Attributes["wx:wTabBefore"].Value);
                    int wCharbBefore = Convert.ToInt32(Math.Round((Double)wTabBefore / charWidth));
                    for (int j = 0; j < wCharbBefore; j++)
                        text += "　";
                }

                XmlNode image = paragraph.SelectSingleNode("w:r/w:pict",nsmgr);
                if (image == null)
                {
                    text += paragraph.InnerText + "\n\r";
                }
                else
                {
                    if (i != 0)
                    {
                        sc.SaveMMSText(mmsID, index.ToString(), "5", text);

                        text = "";

                        index++;
                    }

                    XmlNode imageData = image.SelectSingleNode("v:shape/v:imagedata", nsmgr);
                   //XmlNode binData = image.SelectSingleNode("w:binData",nsmgr);

                    String imageName = imageData.Attributes["src"].Value;
                    String imgPre = imageName.Substring(imageName.LastIndexOf('.') + 1, imageName.Length - imageName.LastIndexOf('.') - 1);


                    Byte[] bb = null;
                    foreach (XmlNode binData in binDatas)
                    {
                        if (binData.Attributes["w:name"].Value == imageName)
                        {
                            bb = Convert.FromBase64String(binData.InnerText);
                            break;
                        }
                    }

                    MemoryStream memoryStream = new MemoryStream(bb);

                    System.Drawing.Bitmap bitmap = new System.Drawing.Bitmap(memoryStream);

                    sc.SaveMMSImage(mmsID, index.ToString(),"5", imgPre, bitmap);

                    memoryStream.Close();
                }
            }

            sc.SaveMMSText(mmsID, index.ToString(), "5", text);

            if (File.Exists(savePath))
            {
                File.Delete(savePath);
            }

            if (File.Exists(osaveFileName.ToString()))
            {
                File.Delete(osaveFileName.ToString());
            }

            Response.Write("<Root><ID>" + mmsID + "</ID></Root>");
        }
        catch (Exception ex)
        {
            if (oDoc != null)
            {
                oDoc.Close(ref oMissing, ref oMissing, ref oMissing);
                Marshal.ReleaseComObject(oDoc);
            }

            if (oWord != null)
            {
                oWord.Quit(ref oMissing, ref oMissing, ref oMissing);
                Marshal.FinalReleaseComObject(oWord);

                oWord = null;
            }

            Response.Write("<Root><ID>-1</ID></Root>");
        }

        Response.End();
    }
}
