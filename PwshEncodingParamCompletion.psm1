using namespace System.Management.Automation
function New-CommandNameInfo {
    Get-Command -Type Cmdlet -ParameterName  Encoding | ForEach-Object name
}


function New-CodepageInfo {
    # 既存のパラメータ
    $DefaultParams = @(
        @{
            Name        = 'ascii'
            Description = 'DEFAULT: Uses the encoding for the ASCII (7-bit) character set.'
        },
        @{
            Name        = 'bigendianunicode'
            Description = 'DEFAULT: Encodes in UTF-16 format using the big-endian byte order.'
        },
        @{
            Name        = 'oem'
            Description = 'DEFAULT: Uses the default encoding for MS-DOS and console programs.'
        },
        @{
            Name        = 'unicode'
            Description = 'DEFAULT: Encodes in UTF-16 format using the little-endian byte order.'
        },
        @{
            Name        = 'utf7'
            Description = 'DEFAULT: Encodes in UTF-7 format.'
        },
        @{
            Name        = 'utf8'
            Description = 'DEFAULT: Encodes in UTF-8 format.'
        },
        @{
            Name        = 'utf8BOM'
            Description = 'DEFAULT: Encodes in UTF-8 format with Byte Order Mark (BOM)'
        },
        @{
            Name        = 'utf8NoBOM'
            Description = 'DEFAULT: Encodes in UTF-8 format without Byte Order Mark (BOM)'
        },
        @{
            Name        = 'utf32'
            Description = 'DEFAULT: Encodes in UTF-32 format.'
        }
    )

    # MSDNのHTMLを取得
    $rest = Invoke-RestMethod 'https://docs.microsoft.com/en-us/dotnet/api/system.text.encoding?view=net-5.0#remarks'
    # 目的のテーブルを取得
    $tbl = ConvertFrom-HtmlTable -Content $rest | Where-Object { $_ | Get-Member 'Code page' }

    $DefaultParams.ForEach{
        [PSCustomObject]@{
            Name                   = $_.Name
            CodePage               = $_.Name
            DisplayName            = $_.Description
            dotnetFrameworkSupport = $true
            dotnetCoreSupport      = $true
        }
    } + $tbl.ForEach{
        [PSCustomObject]@{
            Name                   = $_.Name
            CodePage               = $_.'Code page'
            DisplayName            = $_.'Display name'
            dotnetFrameworkSupport = -not ([string]::IsNullOrEmpty($_.'.NET Framework support'))
            dotnetCoreSupport      = -not ([string]::IsNullOrEmpty($_.'.NET Core support'))
        }
    }
}

function Get-AllCodePages {
        $AllCodePages
}

function Set-CodePages {
    param(
        [Parameter(Mandatory)]
        [psobject]
        $NewCodePages
    )
    end{
        $Script:Codepages = $NewCodePages
    }
}


Function Register-EncodingCompleter {

    $hashArgs = @{
        CommandName   = $CommandName
        ParameterName = 'Encoding'
        ScriptBlock   = {
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            # 入力状態でモードを切り替える
            switch -Regex ($wordToComplete) {
                # 数字が入力されている場合はコードページIDを列挙する
                '^\d' {
                    $Codepages | Where-Object Codepage -Match "$wordToComplete" | ForEach-Object {
                        [CompletionResult]::new(
                            $_.Codepage,
                            ("{0} ({1})" -f $_.Codepage, $_.Name),
                            [CompletionResultType]::Text,
                            $_.Displayname)
                    }
                }
                # それ以外の場合は名称を列挙する
                Default {
                    $Codepages | Where-Object { ($_.Name + $_.Displayname) -Match "$wordToComplete" } | ForEach-Object {
                        [CompletionResult]::new(
                            $_.Name,
                            ("{0} ({1})" -f $_.Name, $_.Codepage),
                            [CompletionResultType]::Text,
                            $_.Displayname)
                    }
                }
            }
        }
    }
    Register-ArgumentCompleter @hashArgs
}

$CommandName = Import-Clixml $PSScriptRoot\CommandName.xml
$AllCodePages = Import-Clixml $PSScriptRoot\Codepages.xml
$CodePages = $AllCodePages | Where-Object {($_.DotnetFrameworkSupport) -or ($_.DisplayName -match 'Japan')}

Export-ModuleMember -Function *