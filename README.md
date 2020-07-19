# PwshEncodingParamCompletion

Encodingパラメータを拡張するPowershellモジュールです。

## これは何？

Powershell7.xはEncodingパラメータに指定可能なエンコードがとても増えましたが、標準の補完入力には9種類しか出てきません。それを何とかするためのモジュールです。

![CompletionName](/assets/CompletionName.png)

数字を入力した状態で補完するとコードページIDから選択出来ます。

![CompletionID](/assets/CompletionID.png)

## 使い方

```powershell
$env:PSModulePath += ";{0}" -f $Pwd.Path
Register-EncodingCompleter
```

#### 全表示

```powershell
$env:PSModulePath += ";{0}" -f $Pwd.Path
Set-AllCodePages (Get-AllCodePages)
Register-EncodingCompleter
```

## 開発環境

```powershell
❯ $PSVersionTable


Name                           Value
----                           -----
PSVersion                      7.0.3
PSEdition                      Core
GitCommitId                    7.0.3
OS                             Microsoft Windows 10.0.19041
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
```

## 作者

[SilkyFowl](https://github.com/SilkyFowl)
