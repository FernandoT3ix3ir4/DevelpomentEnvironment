function installChocolatey () {

    $chocoExists = choco -v;

    if ($null -eq $chocoExists) {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    }

    Write-Information "Chocolatey instalado na versao: ${chocoExists}";
}

function createDevelopmentEnvironment () {
    $tools = @( "jdk8", "maven", "nodejs-lts", "git", "dotnetcore", "dart-sdk", "flutter", "vscode", "AndroidStudio", "android-sdk", "docker");
    foreach ($tool in $tools) {
        choco install $tool -y --accept-license -f;
        setCustomEnvironmentVariables($tool);
        Write-Information "${tool} instalado com sucesso!";
    }

    # Instalação do Angular CLI 7
    npm install -g @angular/cli@7;

}

function setCustomEnvironmentVariables ($tool) {
    $userPath = getUserPath;
    $machinePath = getMachinePath;
    updateFlutterEnvironmentVariable $tool $userPath $machinePath;
}

function updateFlutterEnvironmentVariable ($tool, $userPath, $machinePath) {
    if ($tool -eq 'flutter') {
        $userPath = [System.Text.RegularExpressions.Regex]::Replace($userPath, [System.Text.RegularExpressions.Regex]::Escape("C:\tools\flutter;"), 'C:\tools\flutter\flutter\bin;');
        [System.Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')
        $machinePath = [System.Text.RegularExpressions.Regex]::Replace($machinePath, [System.Text.RegularExpressions.Regex]::Escape("C:\tools\flutter;"), 'C:\tools\flutter\flutter\bin;');
        [System.Environment]::SetEnvironmentVariable('PATH', $machinePath, 'Machine')

        Write-Information "Corrigido a variavel de ambiente Flutter";
    }
}

function getUserPath () {
    $usrPath = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString();

    if (($null) -eq $usrPath -or [String]::Empty -eq $usrPath) {
        [System.Environment]::SetEnvironmentVariable('Path', 'C:\Tmp', 'User');
        $usrPath = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString();
    }

    return $usrPath;
}

function getMachinePath () {
    $machPath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
    $defatulMachinePath = "C:\Program Files (x86)\Common Files\Intel\Shared Libraries\redist\intel64_win\compiler;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;C:\Users\odnan\AppData\Local\Microsoft\WindowsApps;C:\Program Files (x86)\Common Files\Intel\Shared Libraries\redist\intel64_win\compiler;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;"
    if ($null -eq $machPath -or [String]::Empty -eq $machPath) {
        [System.Environment]::SetEnvironmentVariable('Path', $defatulMachinePath, 'Machine');
        $machPath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
    }

    return $machPath;
}

Set-ExecutionPolicy Unrestricted -Scope CurrentUser
Set-ExecutionPolicy Unrestricted -Scope Process
installChocolatey
createDevelopmentEnvironment


Read-Host -Prompt "Pressione [ENTER] para encerrar";