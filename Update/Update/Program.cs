using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;

namespace Update
{
    class Program
    {
        static void Main(string[] args)
        {
            var pathLog = @"D:\dkqn-huangxiang-smsplatform\webService\Log\";

            try
            {
                //foreach (System.Diagnostics.Process thisProc in System.Diagnostics.Process.GetProcesses())
                //{
                //    if (thisProc.ProcessName.ToLower() == "SocketAsyncServer".ToLower())
                //    {
                //        thisProc.Kill();
                //        break;
                //    }
                //}

                var path = @"D:\dkqn-huangxiang-smsplatform\flex_bin\";
                File.AppendAllText(path + @"msg.html", "TestFlex\n");
                //File.Copy(path + @"App_Data\Data.mdb",path + @"Log\Data.xml");
            }
            catch (Exception ex)
            {
                File.AppendAllText(pathLog + @"msg.html", "Error: " + ex.Message + "\n");
            }
        }
    }
}
