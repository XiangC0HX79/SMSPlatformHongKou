using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Sockets;

namespace SocketAsyncServer
{
    class SMS
    {
        private String serviceID;

        private String phone;

        private SocketAsyncEventArgs receiveSendEventArgs;

        public ArrayList smsSendMessages;

        public SMS(SocketAsyncEventArgs e,Dictionary<String,SMS> smsDict,String phone)
        {
            this.receiveSendEventArgs = e;

            String serviceID = (new Random().Next(1000)).ToString();
            while (smsDict.ContainsKey(serviceID))
            {
                serviceID = (new Random().Next(1000)).ToString();
            }
            this.serviceID = serviceID;

            smsDict.Add(this.ServiceID, this);

            this.phone = phone;

            smsSendMessages = new ArrayList();
        }


        public String ServiceID
        {
            get
            {
                return this.serviceID;
            }
        }
        
        public String Phone
        {
            get
            {
                return this.phone;
            }
        }

        public SocketAsyncEventArgs ReceiveSendEventArgs
        {
            get
            {
                return this.receiveSendEventArgs;
            }
        }
    }
}
