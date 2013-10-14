VERSION 5.00
Begin VB.Form frmLogin 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Login"
   ClientHeight    =   1545
   ClientLeft      =   2835
   ClientTop       =   3480
   ClientWidth     =   4035
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   912.837
   ScaleMode       =   0  'User
   ScaleWidth      =   3788.646
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtAccount 
      Height          =   345
      Left            =   1440
      TabIndex        =   1
      Text            =   "0996340900101"
      Top             =   120
      Width           =   2325
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   390
      Left            =   495
      TabIndex        =   4
      Top             =   1020
      Width           =   1140
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   390
      Left            =   2100
      TabIndex        =   5
      Top             =   1020
      Width           =   1140
   End
   Begin VB.TextBox txtPassword 
      Height          =   345
      IMEMode         =   3  'DISABLE
      Left            =   1440
      PasswordChar    =   "*"
      TabIndex        =   3
      Text            =   "ggg"
      Top             =   525
      Width           =   2325
   End
   Begin VB.Label lblLabels 
      Caption         =   "&Account Code:"
      Height          =   270
      Index           =   0
      Left            =   105
      TabIndex        =   0
      Top             =   150
      Width           =   1290
   End
   Begin VB.Label lblLabels 
      Caption         =   "&Password:"
      Height          =   255
      Index           =   1
      Left            =   120
      TabIndex        =   2
      Top             =   600
      Width           =   1065
   End
End
Attribute VB_Name = "frmLogin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
Private Sub cmdCancel_Click()
    Me.Hide
End Sub

Private Sub cmdOK_Click()
Dim hostIP As String
Dim port As Long
Dim result As EMPPLib.ConnectResultEnum

hostIP = "192.168.0.192"
port = "9981"

result = msgCtrl.cn.Connect(hostIP, port, txtAccount.Text, txtPassword.Text)
    If result = CONNECT_OK Then
        Unload Me
        frmMain.Show
    Else
        MsgBox "∏√’ ∫≈µ«¬º ß∞‹£¨¥ÌŒÛ¬Î:" & result & ",«Î÷ÿ ‘£°", , "”√ªßµ«¬º"
        txtPassword.SetFocus
        SendKeys "{Home}+{End}"
    End If
End Sub

Private Sub Form_Load()
    msgCtrl.init
End Sub

