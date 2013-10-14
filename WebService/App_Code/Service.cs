using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

using System.Xml;
using System.Data;
using System.IO;
using System.Text;
using System.Net;
using System.Security.Cryptography;
using System.Net.Mail;

using System.Diagnostics;

using ICSharpCode.SharpZipLib.Zip;

[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消对下行的注释。
// [System.Web.Script.Services.ScriptService]
public class Service : System.Web.Services.WebService
{
    private string conStr = "";

    public Service () {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 

        conStr = System.Configuration.ConfigurationManager.AppSettings["CONSTR"];
    }

    [WebMethod]
    public string HelloWorld() {
        return "Hello World";
    }

    [WebMethod]
    public DataTable GetSysParam()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 系统设置");
    }

    [WebMethod]
    public String SetSysParam(String paramName,String paramValue)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        int resultCount = clsGetData.SetTable("UPDATE 系统设置 SET 参数值 = '" + paramValue + "' WHERE 参数名称 = '" + paramName + "'");
        return resultCount.ToString();        
    }

    [WebMethod]
    public DataTable GetContact()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb",conStr);
        return clsGetData.GetTable("SELECT * FROM 会员名单 WHERE 姓名 <> 'admin' AND 手机号码 <> ''");
    }

    [WebMethod]
    public String StartListen()
    {
        foreach (System.Diagnostics.Process thisProc in System.Diagnostics.Process.GetProcesses())
        {
            if (thisProc.ProcessName.ToLower() == "SocketAsyncServer".ToLower())
            {
                thisProc.Kill();
            }
        }

        try
        {
            String path = Server.MapPath("");

            Process.Start(path + "\\SocketAsyncServer\\SocketAsyncServer.exe", "");
        }
        catch (Exception e)
        {
            return "002";
        }

        return "000";
    }

    [WebMethod]
    public String DeleteContact(String ID)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] IDs = ID.Split(';');
        foreach (String s in IDs)
        {
            if (s != "")
            {
                sql += "DELETE FROM 会员名单 WHERE ID = " + s + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetContact(String contactId, String name, String phone, String group, String mail, String grouppost)
    {
        String ID = "";

        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "SELECT COUNT(*) FROM 会员名单 WHERE  INSTR(手机号码,'"+phone+"') >  0";
        int resultCount = Convert.ToInt32(clsGetData.GetValue(sql));
        if (resultCount > 0)
        {
            return "0001";
        }

        sql = "SELECT COUNT(*) FROM 会员名单 WHERE ID = " + contactId;
        resultCount = Convert.ToInt32(clsGetData.GetValue(sql));
        if (resultCount == 0)
        {
            sql = "INSERT INTO 会员名单 (姓名,手机号码,组别,电子邮箱,组别职务) values ('"
                + name + "','" + phone + "','" + group + "','" + mail + "','" + grouppost + "')";
            resultCount = clsGetData.SetTable(sql);

            if (resultCount == 1)
            {
                ID = clsGetData.GetValue("SELECT MAX(ID) FROM 会员名单").ToString();
            }
        }
        else
        {
            ID = contactId;

            sql = "UPDATE 会员名单 "
                + "SET 姓名 = '" + name + "',"
                + "手机号码 = '" + phone + "',"
                + "组别 = '" + group + "',"
                + "电子邮箱 = '" + mail + "',"
                + "组别职务 = '" + grouppost + "' "
                + "WHERE ID = " + contactId; 
            resultCount = clsGetData.SetTable(sql);
        }

        if (resultCount > 0)
            return "0000|" + ID.ToString();
        else
            return "0002|" + ID.ToString();
    }

    [WebMethod]
    public DataTable GetGroup()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 会员组");
    }

    [WebMethod]
    public String Login(String userName,String passWord)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        DataTable dataTable = clsGetData.GetTable("SELECT ID,手机号码,电子邮箱 FROM  会员名单 WHERE 手机号码 = '" + userName + "'");
        if (dataTable.Rows.Count == 0)
        {
            return "001";//用户不存在
        }

        String id = Convert.ToInt32(dataTable.Rows[0]["ID"]).ToString("000");
        String phone = dataTable.Rows[0]["手机号码"].ToString();
        String mail = dataTable.Rows[0]["电子邮箱"].ToString();

        dataTable = clsGetData.GetTable("SELECT 会员ID,会员密码 FROM 用户名 WHERE 会员ID = '" + dataTable.Rows[0]["ID"].ToString() + "'");
        if (dataTable.Rows.Count == 0)
        {
            return "002|" + phone + "|" + mail;//用户未激活
        }

        if (dataTable.Rows[0]["会员密码"].ToString() != passWord)
        {
            return "003|" + phone + "|" + mail;//用户密码错误
        }

        return "000|" + phone + "|" + mail + "|" + id;
    }
    
    [WebMethod]
    public String ActiveUser(String userName)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        DataTable dataTable = clsGetData.GetTable("SELECT ID,手机号码 FROM 会员名单 WHERE 手机号码 = '" + userName + "'");
        if (dataTable.Rows.Count == 0)
        {
            return "001";//用户不存在
        }
        
        String ID = dataTable.Rows[0]["ID"].ToString();
        String phone = dataTable.Rows[0]["手机号码"].ToString();

        dataTable = clsGetData.GetTable("DELETE FROM 用户名 WHERE 会员ID = '" + dataTable.Rows[0]["ID"].ToString() + "'");
        if (dataTable.Rows.Count == 1)
        {
            //return "002";用户已激活
        }

        int resultCount = clsGetData.SetTable("INSERT INTO 用户名 (会员ID,会员密码) values ('"+ID +"','"+phone +"')");
        if (resultCount == 0)
        {
            return "003";//激活用户失败
        }

        return "000";
    }

    [WebMethod]
    public String SetPassword(String userName, String oldPws, String newPws)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        DataTable dataTable = clsGetData.GetTable("SELECT ID,手机号码 FROM 会员名单 WHERE 姓名 = '" + userName + "' OR 手机号码 = '" + userName + "'");
        if (dataTable.Rows.Count == 0)
        {
            return "001";//用户不存在
        }

        String id = dataTable.Rows[0]["ID"].ToString();
        dataTable = clsGetData.GetTable("SELECT 会员ID,会员密码 FROM 用户名 WHERE 会员ID = '" + id + "'");
        if (dataTable.Rows.Count == 0)
        {
            return "002";//用户未激活
        }

        if (dataTable.Rows[0]["会员密码"].ToString() != oldPws)
        {
            return "003";//用户密码错误
        }

        int count = clsGetData.SetTable("UPDATE 用户名 SET 会员密码 = '" + newPws + "' WHERE 会员ID = '" + id + "'");

        return "000";
    }


    [WebMethod]
    public DataTable GetTask()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 短信_任务");
    }

    [WebMethod]
    public String DeleteTask(String taskName)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] taskNames = taskName.Split(';');
        foreach (String s in taskNames)
        {
            if (s != "")
            {
                sql += "DELETE FROM 短信_任务 WHERE 任务名称 = '" + s + "';";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetTask(String taskName,String taskDate,String taskPhone,String taskMessage,String taskPeoples)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "SELECT COUNT(*) FROM 短信_任务 WHERE 任务名称 = '" + taskName + "'";
        int resultCount = Convert.ToInt32(clsGetData.GetValue(sql));
        if (resultCount == 0)
        {
            sql = "INSERT INTO 短信_任务 (任务名称,时间,手机号码,短信,姓名) values ('"
                + taskName + "','" + taskDate + "','" + taskPhone + "','" + taskMessage + "','" + taskPeoples + "')";
            resultCount = clsGetData.SetTable(sql);
        }
        else
        {
            sql = "UPDATE 短信_任务 "
                + "SET 时间 = '" + taskDate + "',"
                + "手机号码 = '" + taskPhone + "',"
                + "短信 = '" + taskMessage + "' "
                + "姓名 = '" + taskPeoples + "' "
                + "WHERE 任务名称 = '" + taskName + "'";
            resultCount = clsGetData.SetTable(sql);
        }

        return resultCount.ToString();
    }

    [WebMethod]
    public DataTable GetHoliday()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 短信_节日祝福语");
    }

    [WebMethod]
    public String DeleteHoliday(String id)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] IDs = id.Split(';');
        foreach (String s in IDs)
        {
            if (s != "")
            {
                sql += "DELETE FROM 短信_节日祝福语 WHERE ID = " + s + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetHoliday(String draftID, String draftMonth,String draftDate,String draftName, String draftMessage,String draftType)
    {
        String ID = "";

        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "SELECT COUNT(*) FROM 短信_节日祝福语 WHERE ID = " + draftID;
        int resultCount = Convert.ToInt32(clsGetData.GetValue(sql));
        if (resultCount == 0)
        {
            sql = "INSERT INTO 短信_节日祝福语 (月,日,节日名称,短信,类型) values ('"
                + draftMonth + "','" + draftDate + "','" + draftName + "','" + draftMessage + "','" + draftType + "')";
            resultCount = clsGetData.SetTable(sql);

            if (resultCount == 1)
            {
                ID = clsGetData.GetValue("SELECT MAX(ID) FROM 短信_节日祝福语").ToString();
            }
        }
        else
        {
            ID = draftID;

            sql = "UPDATE 短信_节日祝福语 "
                + "SET 月 = '" + draftMonth + "',"
                + "日 = '" + draftDate + "', "
                + "节日名称 = '" + draftName + "', "
                + "短信 = '" + draftMessage + "', "
                + "类型 = '" + draftType + "' "
                + "WHERE ID = " + draftID;
            resultCount = clsGetData.SetTable(sql);
        }

        return ID;
    }

    [WebMethod]
    public DataTable GetDraft()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 短信_草稿箱");
    }

    [WebMethod]
    public String DeleteDraft(String draftID)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] taskNames = draftID.Split(';');
        foreach (String s in taskNames)
        {
            if (s != "")
            {
                sql += "DELETE FROM 短信_草稿箱 WHERE ID = " + s + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetDraft(String draftID,String draftPhone, String draftMessage,String people)
    {
        String ID = "";

        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "SELECT COUNT(*) FROM 短信_草稿箱 WHERE ID = " + draftID;
        int resultCount = Convert.ToInt32(clsGetData.GetValue(sql));
        if (resultCount == 0)
        {
            sql = "INSERT INTO 短信_草稿箱 (手机号码,短信,姓名) values ('"
                + draftPhone + "','" + draftMessage + "','" + people + "')";
            resultCount = clsGetData.SetTable(sql);

            if (resultCount == 1)
            {
                ID = clsGetData.GetValue("SELECT MAX(ID) FROM 短信_草稿箱").ToString();
            }
        }
        else
        {
            ID = draftID;

            sql = "UPDATE 短信_草稿箱 "
                + "SET 手机号码 = '" + draftPhone + "',"
                + "短信 = '" + draftMessage + "', "
                + "姓名 = '" + people + "' "
                + "WHERE ID = " + draftID;
            resultCount = clsGetData.SetTable(sql);
        }

        return ID;
    }

    [WebMethod]
    public DataTable GetReceive()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 短信_收件箱 ORDER BY 时间 DESC");
    }

    [WebMethod]
    public String DeleteReceive(String IDs)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] taskNames = IDs.Split(';');
        foreach (String id in taskNames)
        {
            if (id != "")
            {
                sql += "DELETE FROM 短信_收件箱 WHERE ID = " + id + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetReceive(String phone, String message)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String people = "";
        Object o = clsGetData.GetValue("SELECT 姓名 FROM 会员名单 WHERE InStr(手机号码,'" + phone + "') > 0");
        if (o != null)
            people = o.ToString();

        String sql = "INSERT INTO 短信_收件箱 (时间,手机号码,短信,姓名) values (now(),'"
                + phone + "','" + message + "','" + people + "')";

        int count = clsGetData.SetTable(sql);

        return count.ToString();
    }

    [WebMethod]
    public DataTable GetSend(String status)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        String sql = "SELECT * FROM 短信_发件箱";
        if (status != "")
            sql += " WHERE 状态 = '" + status + "'";
        sql += " ORDER BY 时间 DESC";
        return clsGetData.GetTable(sql);
    }

    [WebMethod]
    public String DeleteSend(String IDs)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] taskNames = IDs.Split(';');
        foreach (String id in taskNames)
        {
            if (id != "")
            {
                sql += "DELETE FROM 短信_发件箱 WHERE ID = " + id + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String InsertSend(String phone, String message,String status)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String people = "";
        Object o = clsGetData.GetValue("SELECT 姓名 FROM 会员名单 WHERE InStr(手机号码,'" + phone + "') > 0");
        if (o != null)
            people = o.ToString();

        String sql = "INSERT INTO 短信_发件箱 (时间,手机号码,短信,状态,姓名) values (now(),'"
                + phone + "','" + message + "','" + status + "','" + people + "')";

        int resultCount = clsGetData.SetTable(sql);
        if (resultCount > 0)
        {
            sql = "SELECT MAX(ID) FROM 短信_发件箱";
            return clsGetData.GetValue(sql).ToString();
        }
        else
        {
            return resultCount.ToString();
        }
    }

    [WebMethod]
    public String UpdateSend(String ID,String status,String msgID)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "";
        if (ID == "")
        {
            sql = "SELECT ID FROM 短信_发件箱 WHERE 短信ID = '" + msgID + "'";
            int id = Convert.ToInt32(clsGetData.GetValue(sql));

            sql = "UPDATE 短信_发件箱 SET 状态 = '" + status + "'"
                + ",时间 = now()"
                +  " WHERE ID = " + id;
        }
        else
        {
            sql = "UPDATE 短信_发件箱 SET 状态 = '" + status + "'"
                + ",时间 = now()"
                + ",短信ID = '" + msgID + "'"
                + " WHERE ID = " + ID; 
        }

        int resultCount = clsGetData.SetTable(sql);
        return resultCount.ToString();
    }


    [WebMethod]
    public DataTable GetPhraseGroup()
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 短语组");
    }

    [WebMethod]
    public String DeletePhraseGroup(String IDs)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] taskNames = IDs.Split(';');
        foreach (String id in taskNames)
        {
            if (id != "")
            {
                sql += "DELETE FROM 短语组 WHERE ID = " + id + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetPhraseGroup(String name)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "INSERT INTO 短语组 (组名) values ('" + name + "')";

        int resultCount = clsGetData.SetTable(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public DataTable GetPhrase(String groupID)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 短语 WHERE 组ID = "+ groupID);
    }

    [WebMethod]
    public String DeletePhrase(String IDs)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] taskNames = IDs.Split(';');
        foreach (String id in taskNames)
        {
            if (id != "")
            {
                sql += "DELETE FROM 短语 WHERE ID = " + id + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetPhrase(String groupID,String message)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sql = "INSERT INTO 短语 (时间,短语,组ID) values (now(),'" + message + "'," + groupID + ")";

        int resultCount = clsGetData.SetTable(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public DataTable GetMMS(String type)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        return clsGetData.GetTable("SELECT * FROM 彩信_发件箱 WHERE 状态 ='" + type + "' ORDER BY 时间 DESC");
    }

    [WebMethod]
    public String GetMMSFile(String ID)
    {
        String path = Server.MapPath("MMS");
        path += "\\F" + ID;

        XmlDocument xmlDoc = new XmlDocument();
        xmlDoc.Load(path + "\\mms.smil");
        return xmlDoc.OuterXml;
    }

    [WebMethod]
    public String SetMMS(String phone,String title,String type,String people)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);
        //String sql = "";

        //if (mmsID != "-1")
        //{
        //    sql = "DELETE FROM 彩信_发件箱 WHERE ID =" + mmsID;

        //    clsGetData.SetTable(sql);
        //}

        string path = Server.MapPath("MMS");
        
        String ID = "";
        String sql = "INSERT INTO 彩信_发件箱 (时间,手机号码,标题,状态,姓名) values (now(),'"
                + phone + "','" + title + "','" + type + "','" + people + "')";

        int resultCount = clsGetData.SetTable(sql);
        if (resultCount == 1)
        {
            ID = clsGetData.GetValue("SELECT MAX(ID) FROM 彩信_发件箱").ToString();

            path += "\\F" + ID;

            if (Directory.Exists(path))
            {
                foreach(String fileName in Directory.GetFiles(path))
                {
                    File.Delete(fileName);
                }

                Directory.Delete(path);
            }

            Directory.CreateDirectory(path);

            WriteToFile(path + "\\title.txt", title, true, Encoding.GetEncoding(936));

            WriteToFile(path + "\\mms.smil", "<smil xmlns=\"http://www.w3.org/2000/SMIL20/CR/Language\">", false, Encoding.UTF8);
            //WriteToFile(path + "\\mms.smil", "<smil>", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "<head>", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "<layout>", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "<root-layout width=\"240\" height=\"320\" />", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "<region id=\"img_region\" width=\"240\" height=\"200\" left=\"0\" top=\"0\" />", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "<region id=\"text_region\" width=\"240\" height=\"120\" left=\"0\" top=\"200\" />", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "</layout>", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "</head>", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "<body>", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "</body>", false, Encoding.UTF8);
            WriteToFile(path + "\\mms.smil", "</smil>", false, Encoding.UTF8);
        }

        return ID;
    }

    [WebMethod]
    public String SaveMMS(String ID)
    {
        String sourcepath = Server.MapPath("MMS") + "\\F" + ID;
        Queue<FileSystemInfo> Folders = new Queue<FileSystemInfo>(new DirectoryInfo(sourcepath).GetFileSystemInfos());
        String copytopath = Server.MapPath("MMS") + "\\F" + ID + ".zip";
        //copytopath = (copytopath.LastIndexOf(Path.DirectorySeparatorChar) == copytopath.Length - 1) ? copytopath : copytopath + Path.DirectorySeparatorChar + Path.GetFileName(sourcepath);
        //Directory.CreateDirectory(copytopath);
        ZipFile zip = ZipFile.Create(copytopath);
        zip.BeginUpdate();
        while (Folders.Count > 0)
        {
            FileSystemInfo atom = Folders.Dequeue();
            FileInfo sourcefile = atom as FileInfo;
            if (sourcefile != null)
            {
                    zip.Add(sourcefile.FullName, sourcefile.Name);
            }
        }
        zip.CommitUpdate();
        zip.Close();

        return "000";
    }

    [WebMethod]
    public String SendMMS(String ID)
    {
        const String Customer_id = "3567";
        const String Corp_Account = "201203071707300692";
        const String Token = "d5dcd6ee-c7e2-4d7a-a3c0-6d90ebb9052e";
        const String agreement_id = "4673";

        //const String Customer_id = "5528";
        //const String Corp_Account = "201206081324510088";
        //const String Token = "1284725e-2d71-4486-996e-68c7c534bce7";
        //const String agreement_id = "6490";

        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        String sourcepath = Server.MapPath("MMS") + "\\F" + ID + ".zip";

        Byte[] bt = new Byte[1];
        String s = "";

        FileStream fs = new FileStream(sourcepath, FileMode.Open);
        if(fs.Length > 60 * 1024)
        {
            fs.Close();

            clsGetData.SetTable("UPDATE 彩信_发件箱 SET 状态 = '发送失败' WHERE ID =" + ID);
            return "0100";
        }

        for(long i=0;i<fs.Length;i++)
        {
            fs.Read(bt, 0, 1);
            s += String.Format("{0:X2}", bt[0]);
        }
        fs.Close();

        //String tokenID = "1284725e-2d71-4486-996e-68c7c534bce7";
        Byte[] tokenByte = Encoding.Default.GetBytes(Token);
        MD5 md5 = new MD5CryptoServiceProvider();
        
        Byte[] output = md5.ComputeHash(tokenByte);
        String md5_token = BitConverter.ToString(output).Replace("-", ""); 

        String baseUrl = "http://221.179.195.70/eepwww/TaskServlet";
        //String url = baseUrl + "?Method=GetTaskList&Customer_id=5528&Corp_Account=201206081324510088&Token=" + md5_token + "&START=1&END=10";

        String url = baseUrl + "?Method=AddTask&"
            + "Customer_id=" + Customer_id 
            + "&Corp_Account=" + Corp_Account 
            + "&Type=1&Token=" + md5_token 
            + "&Agreement_id=" + agreement_id;

        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
        request.Method = "POST";

        WebResponse response = request.GetResponse();
        Stream readerStream = response.GetResponseStream();
        XmlDocument xmlDoc = new XmlDocument();
        xmlDoc.Load(readerStream);

        XmlNode nodeCode = xmlDoc.GetElementsByTagName("Code")[0];
        if (nodeCode.InnerText != "0000")
        {
            clsGetData.SetTable("UPDATE 彩信_发件箱 SET 状态 = '发送失败' WHERE ID =" + ID);
            return nodeCode.InnerText;
        }

        XmlNode nodeTaskID = xmlDoc.GetElementsByTagName("TaskID")[0];
        String taskID = nodeTaskID.InnerText;

        string param = "Method=AddContent&"
            + "Customer_id=" + Customer_id 
            + "&Corp_Account=" + Corp_Account 
            + "&TaskID=" + taskID 
            + "&MmsType=1&Mms=" + s 
            + "&Token=" + md5_token;
        
        byte[] bs = Encoding.UTF8.GetBytes(param);

        //url = baseUrl + "?Method=AddContent&Customer_id=5528&Corp_Account=201206081324510088&TaskID=" + taskID + "&MmsType=1&Mms=" + s + "&Token=" + md5_token;
        
        request = (HttpWebRequest)WebRequest.Create(baseUrl);
        request.Method = "POST";
        request.ContentType = "application/x-www-form-urlencoded";
        request.ContentLength = bs.Length;

        using (Stream reqStream = request.GetRequestStream())
        {
            reqStream.Write(bs, 0, bs.Length);
        }
        
        response = request.GetResponse();
        readerStream = response.GetResponseStream();
        xmlDoc.Load(readerStream);

        nodeCode = xmlDoc.GetElementsByTagName("Code")[0];
        if (nodeCode.InnerText != "0000")
        {
            clsGetData.SetTable("UPDATE 彩信_发件箱 SET 状态 = '发送失败' WHERE ID =" + ID);
            return nodeCode.InnerText;
        }
        
        String phones = clsGetData.GetValue("SELECT 手机号码 FROM 彩信_发件箱 WHERE ID = " + ID).ToString();
        String[] mobs = phones.Split(';');
        String Mobile = ""; //mobs[0];

        //cn.com.webxml.webservice.MobileCodeWS mobileWS = new cn.com.webxml.webservice.MobileCodeWS();

        for(int i =0;i<mobs.Length;i++)
        {
            if (mobs[i] != "")
            {
                //String rr = mobileWS.getMobileCodeInfo(mobs[i], "5384ed874a044df69c16790073939f64");

                //if (rr.IndexOf("移动") == -1)
                //{
                    if (Mobile == "")
                    {
                        Mobile = mobs[i];
                    }
                    else
                    {
                        Mobile += "," + mobs[i];
                    }
                //}
            }
        }

        //url = baseUrl + "?Method=AddWhiteList&Customer_id=5528&Corp_Account=201206081324510088&Token=" + md5_token + "&TaskID=" + taskID + "&Mobile=" + Mobile;
        param = "Method=AddWhiteList&"
            + "Customer_id=" + Customer_id 
            + "&Corp_Account=" + Corp_Account 
            + "&Token=" + md5_token 
            + "&TaskID=" + taskID 
            + "&Mobile=" + Mobile;
        
        bs = Encoding.UTF8.GetBytes(param);
        
        request = (HttpWebRequest)WebRequest.Create(baseUrl);
        request.Method = "POST";
        request.ContentType = "application/x-www-form-urlencoded";
        request.ContentLength = bs.Length;

        using (Stream reqStream = request.GetRequestStream())
        {
            reqStream.Write(bs, 0, bs.Length);
        }

        response = request.GetResponse();
        readerStream = response.GetResponseStream();
        xmlDoc.Load(readerStream);

        nodeCode = xmlDoc.GetElementsByTagName("Code")[0];
        if (nodeCode.InnerText != "0000")
        {            
            clsGetData.SetTable("UPDATE 彩信_发件箱 SET 状态 = '发送失败' WHERE ID =" + ID);
        }
        else
        {
            clsGetData.SetTable("UPDATE 彩信_发件箱 SET 状态 = '发送成功' WHERE ID =" + ID);
        }
        return nodeCode.InnerText;
    }

    public void WriteToFile(string name, string content, bool isCover,Encoding encoding)
    {
        FileStream fs = null;
        try
        {
            if (!isCover && File.Exists(name))
            {
                fs = new FileStream(name, FileMode.Append, FileAccess.Write);
                StreamWriter sw = new StreamWriter(fs, encoding);
                sw.WriteLine(content);
                sw.Flush();
                sw.Close();
            }
            else
            {
                File.WriteAllText(name, content, encoding);
            }
        }
        finally
        {
            if (fs != null)
            {
                fs.Close();
            }
        }

    }

    [WebMethod]
    public String DeleteMMS(String IDs)
    {
        ClsGetData clsGetData = new ClsGetData("System.Data.OleDb", conStr);

        int resultCount = 0;
        String sql = "";
        String[] taskNames = IDs.Split(';');
        foreach (String id in taskNames)
        {
            if (id != "")
            {
                sql += "DELETE FROM 彩信_发件箱 WHERE ID = " + id + ";";
            }
        }

        resultCount = clsGetData.ExcuteNoQuery(sql);

        return resultCount.ToString();
    }

    [WebMethod]
    public String SetMail()
    {
        String path = Server.MapPath("MAIL");
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
            Directory.Delete(path);
        }
        else
        {
            String[] strFiles = Directory.GetFiles(path);
            foreach (string strFile in strFiles)
            {
                File.Delete(strFile);
            }
        }

        return "000";
    }

    [WebMethod]
    public String SendMail(String fromName,String fromMail,String fromPassword,String toMail,String mailTitle,String mailMain)
    {
        SmtpClient smtp = new SmtpClient(); //实例化一个SmtpClient

        smtp.DeliveryMethod = SmtpDeliveryMethod.Network; //将smtp的出站方式设为 Network

        smtp.EnableSsl = false;//smtp服务器是否启用SSL加密

        String webAddr = fromMail.Substring(fromMail.IndexOf('@') + 1);
        smtp.Host = "smtp." + webAddr; //指定 smtp 服务器地址

        smtp.Port = 25;             //指定 smtp 服务器的端口，默认是25，如果采用默认端口，可省去

        //如果你的SMTP服务器不需要身份认证，则使用下面的方式，不过，目前基本没有不需要认证的了

        //smtp.UseDefaultCredentials = true;

        //如果需要认证，则用下面的方式

        smtp.Credentials = new NetworkCredential(fromMail, fromPassword);

        MailMessage mm = new MailMessage(); //实例化一个邮件类

        mm.Priority = MailPriority.Normal; //邮件的优先级，分为 Low, Normal, High，通常用 Normal即可

        mm.From = new MailAddress(fromMail, fromName, Encoding.UTF8);

        //收件方看到的邮件来源；

        //第一个参数是发信人邮件地址

        //第二参数是发信人显示的名称

        //第三个参数是 第二个参数所使用的编码，如果指定不正确，则对方收到后显示乱码

        //936是简体中文的codepage值

        //注：上面的邮件来源，一定要和你登录邮箱的帐号一致，否则会认证失败

        //mm.ReplyTo = new MailAddress("test_box@gmail.com", "我的接收邮箱", Encoding.GetEncoding(936));

        //ReplyTo 表示对方回复邮件时默认的接收地址，即：你用一个邮箱发信，但却用另一个来收信

        //上面后两个参数的意义， 同 From 的意义

        //mm.CC.Add("hx_smm@Hotmail.com");

        //邮件的抄送者，支持群发，多个邮件地址之间用 半角逗号 分开



        //当然也可以用全地址，如下：

        //mm.CC.Add(new MailAddress("a@163.com", "抄送者A", Encoding.GetEncoding(936)));

        //mm.CC.Add(new MailAddress("b@163.com", "抄送者B", Encoding.GetEncoding(936)));

        //mm.CC.Add(new MailAddress("c@163.com", "抄送者C", Encoding.GetEncoding(936)));



        //mm.Bcc.Add("d@163.com,e@163.com");

        //邮件的密送者，支持群发，多个邮件地址之间用 半角逗号 分开



        //当然也可以用全地址，如下：

        //mm.CC.Add(new MailAddress("d@163.com", "密送者D", Encoding.GetEncoding(936)));

        //mm.CC.Add(new MailAddress("e@163.com", "密送者E", Encoding.GetEncoding(936)));

        //mm.Sender = new MailAddress("xxx@xxx.com", "邮件发送者", Encoding.GetEncoding(936));

        //可以任意设置，此信息包含在邮件头中，但并不会验证有效性，也不会显示给收件人

        //说实话，我不知道有啥实际作用，大家可不理会，也可不写此项

        mm.To.Add(toMail);

        //邮件的接收者，支持群发，多个地址之间用 半角逗号 分开



        //当然也可以用全地址添加



        //mm.To.Add(new MailAddress("g@163.com", "接收者g", Encoding.GetEncoding(936)));

        //mm.To.Add(new MailAddress("h@163.com", "接收者h", Encoding.GetEncoding(936)));

        mm.Subject = mailTitle; //邮件标题

        mm.SubjectEncoding = Encoding.UTF8;// .GetEncoding(936);

        // 这里非常重要，如果你的邮件标题包含中文，这里一定要指定，否则对方收到的极有可能是乱码。

        // 936是简体中文的pagecode，如果是英文标题，这句可以忽略不用

        mm.IsBodyHtml = false; //邮件正文是否是HTML格式



        mm.BodyEncoding = Encoding.UTF8;// .GetEncoding(936);

        //邮件正文的编码， 设置不正确， 接收者会收到乱码



        mm.Body = mailMain;

        //邮件正文
        
        String path = Server.MapPath("MAIL");
        if (Directory.Exists(path))
        {
            //DirectoryInfo TheFolder = new DirectoryInfo(path);
            String[] strFiles = Directory.GetFiles(path);
            foreach (string strFile in strFiles)
            {
                mm.Attachments.Add(new Attachment(strFile)); 
            }
            //mm.Attachments.Add( new Attachment( @"d:a.doc", System.Net.Mime.MediaTypeNames.Application.Rtf ) );

            //添加附件，第二个参数，表示附件的文件类型，可以不用指定

            //可以添加多个附件

            //mm.Attachments.Add( new Attachment( @"d:b.doc") );
        }


        try
        {
            smtp.Send(mm); //发送邮件，如果不返回异常， 则大功告成了。
        }
        catch (Exception e)
        {
            return "001";
        }

        return "000";
    }

    public void SaveMMSImage(String ID, String index, String dur, String imgPre, System.Drawing.Bitmap image)
    {
        if (ID == null)
            return;

        String path = Server.MapPath("MMS") + "\\F" + ID;

        XmlDocument xmlDoc = new XmlDocument();
        xmlDoc.Load(path + "\\mms.smil");

        XmlElement parNode = xmlDoc.GetElementsByTagName("par")[Convert.ToInt16(index)] as XmlElement;
        if (parNode == null)
        {
            parNode = xmlDoc.CreateElement("par", xmlDoc.DocumentElement.NamespaceURI);
            parNode.SetAttribute("dur", dur + "s");

            XmlNode bodyNode = xmlDoc.GetElementsByTagName("body")[0];
            bodyNode.AppendChild(parNode);
        }

        String imgName = "img" + index + "." + imgPre;
        image.Save(path + "\\" + imgName);

        XmlElement imgNode = xmlDoc.CreateElement("img", xmlDoc.DocumentElement.NamespaceURI); ;
        imgNode.SetAttribute("src", imgName);
        imgNode.SetAttribute("region", "img_region");

        parNode.AppendChild(imgNode);

        XmlTextWriter writer = new XmlTextWriter(path + "\\mms.smil", Encoding.UTF8);
        xmlDoc.WriteTo(writer);
        writer.Close();
    }

    public void SaveMMSText(String ID, String index, String dur, String text)
    {
        if (ID == null)
            return;

        String path = Server.MapPath("MMS") + "\\F" + ID;

        String textName = "txt" + index + ".txt";

        XmlDocument xmlDoc = new XmlDocument();
        xmlDoc.Load(path + "\\mms.smil");

        XmlElement parNode = xmlDoc.GetElementsByTagName("par")[Convert.ToInt16(index)] as XmlElement;
        if (parNode == null)
        {
            parNode = xmlDoc.CreateElement("par", xmlDoc.DocumentElement.NamespaceURI);
            parNode.SetAttribute("dur", dur + "s");

            XmlNode bodyNode = xmlDoc.GetElementsByTagName("body")[0];
            bodyNode.AppendChild(parNode);
        }

        WriteToFile(path + "\\" + textName, text, true);

        XmlElement textNode = xmlDoc.CreateElement("text", xmlDoc.DocumentElement.NamespaceURI);
        textNode.SetAttribute("src", textName);
        textNode.SetAttribute("region", "text_region");

        parNode.AppendChild(textNode);

        XmlTextWriter writer = new XmlTextWriter(path + "\\mms.smil", Encoding.UTF8);
        xmlDoc.WriteTo(writer);
        writer.Close();
    }

    private void WriteToFile(string name, string content, bool isCover)
    {
        Encoding gbkencoding = Encoding.GetEncoding(936);
        FileStream fs = null;
        try
        {
            if (!isCover && File.Exists(name))
            {
                fs = new FileStream(name, FileMode.Append, FileAccess.Write);
                StreamWriter sw = new StreamWriter(fs, gbkencoding);
                sw.WriteLine(content);
                sw.Flush();
                sw.Close();
            }
            else
            {
                File.WriteAllText(name, content, gbkencoding);
            }
        }
        finally
        {
            if (fs != null)
            {
                fs.Close();
            }
        }

    }
}
