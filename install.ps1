<#
.SYNOPSIS
    Scoopパッケージマネージャーを使用してchezmoiをインストールします。
.PARAMETER Pause
    スクリプトの終了時にユーザーのコンソール入力を待機します。
.PARAMETER NoInit
    chezmoiコマンドを実行せずに終了します。
.PARAMETER ArgumentList
    chezmoiコマンドの実行時に指定するパラメーターを指定します。
#>
param(
    [switch]$Pause,
    [switch]$NoInit,
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$ArgumentList
)

# エラートラップの設定
$ErrorActionPreference = 'Stop'

function Install-Scoop {
    # Scoopがインストールされているか確認
    if (!(Get-Command 'scoop' -ErrorAction SilentlyContinue)) {
        # インストールディレクトリの設定 (user)
        $env:SCOOP = 'C:\ProgramData\Scoop'
        [Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
        # インストールディレクトリの設定 (global)
        $env:SCOOP_GLOBAL = 'C:\ProgramData\Scoop'
        [Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

        # Scoopのインストール
        # Set-ExecutionPolicy RemoteSigned -Scope Process
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh') # DevSkim: ignore DS104456
    }
}

# デバッグモードで実行された場合
if ($PSBoundParameters['Debug']) {
    # スクリプトの引数をダンプ
    Write-Output "Pause: $Pause"
    for ($index = 0; $index -lt $ArgumentList.count; $index++) {
        Write-Output ("ArgumentList[{0}]: {1}" -f $index, $ArgumentList[$index])
    }
}

# 現在の権限を取得し、管理者権限があるか確認
$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if ($principal.IsInRole('Administrators')) {
    # chezmoiがインストールされているか確認
    if (!(Get-Command 'chezmoi' -ErrorAction SilentlyContinue)) {
        Write-Output 'Installing chezmoi via Scoop'
        # scoopのインストール
        Install-Scoop
        # chezmoiのインストール
        scoop install chezmoi
    }

    # gitがインストールされているか確認
    if (!(Get-Command 'git' -ErrorAction SilentlyContinue)) {
        Write-Output 'Installing git via Scoop'
        # scoopのインストール
        Install-Scoop
        # gitのインストール
        scoop install git
    }
} else {
    # 管理者権限でこのスクリプトを実行
    # $scriptArgs = "'{0}'" -f ($ArgumentList -join "' '")
    # $processArgs = "-ExecutionPolicy RemoteSigned -Command & '{0}' -Pause -- {1}" -f $PSCommandPath, $scriptArgs
    $processArgs = "-ExecutionPolicy RemoteSigned -File `"${PSCommandPath}`" -NoInit"
    Write-Output ('Running "powershell.exe {0}" as Administrator' -f $processArgs)
    Start-Process -FilePath powershell.exe -ArgumentList "$processArgs" -Verb RunAs -Wait
}

if (!$NoInit) {
    git config --global core.autocrlf false
    $ArgumentList = @('init', '--apply') + $ArgumentList
    Write-Output "Running 'chezmoi $ArgumentList'"
    chezmoi $ArgumentList
}

if ($Pause) {
    # ユーザーのコンソール入力を待機
    Read-Host 続行するには、Enter キーを押してください...
}
