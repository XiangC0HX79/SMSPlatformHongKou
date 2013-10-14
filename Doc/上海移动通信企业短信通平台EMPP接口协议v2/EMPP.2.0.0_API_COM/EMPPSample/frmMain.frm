VERSION 5.00
Begin VB.Form frmMain 
   Caption         =   "Form1"
   ClientHeight    =   4620
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   6645
   BeginProperty Font 
      Name            =   "宋体"
      Size            =   9
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4620
   ScaleWidth      =   6645
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame Frame1 
      Height          =   135
      Left            =   0
      TabIndex        =   6
      Top             =   3840
      Width           =   6615
   End
   Begin VB.TextBox txtMsg 
      Height          =   2655
      Left            =   120
      TabIndex        =   3
      Text            =   "test"
      Top             =   1200
      Width           =   6375
   End
   Begin VB.TextBox txtReceiver 
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Text            =   "13817599235"
      Top             =   360
      Width           =   6375
   End
   Begin VB.CommandButton cmdClose 
      Caption         =   "关  闭(&C)"
      Height          =   375
      Left            =   5160
      TabIndex        =   5
      Top             =   4080
      Width           =   1215
   End
   Begin VB.CommandButton cmdSend 
      Caption         =   "发  送(&S)"
      Default         =   -1  'True
      Height          =   375
      Left            =   3480
      TabIndex        =   4
      Top             =   4080
      Width           =   1215
   End
   Begin VB.Label Label2 
      Caption         =   "短信内容(&M):"
      Height          =   255
      Left            =   240
      TabIndex        =   2
      Top             =   960
      Width           =   1215
   End
   Begin VB.Label Label1 
      Caption         =   "收信人(&R):"
      Height          =   255
      Left            =   240
      TabIndex        =   0
      Top             =   120
      Width           =   1095
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmdClose_Click()
    msgCtrl.cn.disconnect
    Unload Me
End Sub

Private Sub cmdSend_Click()
Dim msg As New EMPPLib.ShortMessage
Dim mobiles As New EMPPLib.mobiles
 
 For Each a In Split(txtReceiver.Text, ",")
    mobiles.Add a
 Next
    

'mobiles.Add txtReceiver.Text

msg.DestMobiles = mobiles
msg.content = txtMsg.Text
msg.needStatus = True           '需要状态报告
msg.ServiceID = "0996340900"    'ServiceID随帐号帐号不同而改变，请在此处填写自己正确的ServiceID值
msg.SendNow = True
msg.srcID = msgCtrl.cn.AccountID
msg.SequenceID = 123


msgCtrl.cn.needStatus = True '需要状态报告，真正起作用的是这个属性
If msgCtrl.cn.connected Then
    msgCtrl.cn.submit msg
End If

txtMsg.Text = ""

Set mobiles = Nothing
Set msg = Nothing

End Sub


