using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Collections;

using EMPPLib;

namespace SocketAsyncServer
{
    class SMSSendMessage
    {
        private ShortMessage shortMsg;

        public String MsgID;

        public SMDeliverd Deliverd;

        public SMSSendMessage(ShortMessage shortMsg)
        {
            this.shortMsg = shortMsg;
        }

        public ShortMessage ShortMsg
        {
            get
            {
                return this.shortMsg;
            }
        }
    }
}
