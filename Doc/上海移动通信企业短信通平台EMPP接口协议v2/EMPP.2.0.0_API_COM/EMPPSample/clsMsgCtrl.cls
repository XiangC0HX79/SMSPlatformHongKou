VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMsgCtrl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public WithEvents cn As EMPPLib.emptcl
Attribute cn.VB_VarHelpID = -1
Public Function init()
    Set cn = New EMPPLib.emptcl
End Function


Private Sub cn_EMPPClosed(ByVal errorCode As Long)
If Not frmLogin Then
    frmLogin.cmdOK_Click
End If
End Sub

Private Sub cn_MessageReceivedInterface(ByVal sm As EMPPLib.ISMDeliverd)
    Dim sMsg As String
    sMsg = "发送方号码:" & sm.srcID & ":接收方号码:" & sm.DestID & _
        ";短信格式:" & sm.MsgFmt & ";短信长度:" & sm.MsgLength & _
        ";发送方号码类型:" & sm.SrcTerminalType & ";短信内容:" & sm.content & _
        ";MsgID:" & sm.MsgID & ";ServiceID:" & sm.ServiceID
    MsgBox sMsg, , "接收短信"
End Sub

Private Sub cn_SocketClosed(ByVal errorCode As Long)
If Not frmLogin Then
    frmLogin.cmdOK_Click
End If
End Sub

Private Sub cn_StatusReceivedInterface(ByVal sm As EMPPLib.IStatusReport)
    Dim sReportStatus As String
    sReportStatus = "发送方号码:" & Trim(sm.SrcTerminalId) & ";接收方号码:" & sm.DestID & _
                    ";接收短信时间:" & sm.submitDatetime & ";发送短信时间:" & sm.doneDatetime & _
                    ";短信接收状态:" & sm.Status & ";ServiceID:" & sm.ServiceID & _
                    ";MsgID:" & sm.MsgID & ";SeqID:" & sm.SeqID
    
    MsgBox sReportStatus, , "状态报告"
End Sub

Private Sub cn_SubmitRespInterface(ByVal sm As EMPPLib.ISubmitResp)
    Dim result As Long
    result = sm.result
End Sub

