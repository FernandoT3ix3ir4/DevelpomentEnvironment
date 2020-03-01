function installChocolatey () {

    $chocoExists = choco -v;

    if ($null -eq $chocoExists) {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));
    }

    Write-Information "Chocolatey instalado na versao: ${chocoExists}";
}

function createDevelopmentEnvironment () {
    $tools = @("nodejs-lts", "maven", "vscode", "jdk8", "git", "docker", "dotnetcore", "dart-sdk", "flutter", "AndroidStudio", "android-sdk");
    foreach ($tool in $tools) {
        choco install $tool -y --accept-license;
        setCustomEnvironmentVariables($tool);
        Write-Information "${tool} instalado com sucesso!";
    }
}

function setCustomEnvironmentVariables ($tool) {
    $userPath = getUserPath;
    $machinePath = getMachinePath;
    updateFlutterEnvironmentVariable($tool, $userPath, $machinePath);
    addCodeEnvironmentVariable($tool, $userPath);
}

function addCodeEnvironmentVariable ($tool, $userPath) {
    if ($tool -eq 'vscode') {
        $vsCodePath = "C:\Program Files\Microsoft VS Code\bin";
        [System.Environment]::SetEnvironmentVariable('PATH', $userPath + $vsCodePath, 'User');
    }
}
function updateFlutterEnvironmentVariable ($tool, $userPath, $machinePath) {
    if ($tool -eq 'flutter') {
        $userPath = [System.Text.RegularExpressions.Regex]::Replace($userPath, [System.Text.RegularExpressions.Regex]::Escape("C:\tools\flutter;"), 'C:\tools\flutter\flutter\bin;');
        [System.Environment]::SetEnvironmentVariable('Path', $userPath, 'User')
        $machinePath = [System.Text.RegularExpressions.Regex]::Replace($machinePath, [System.Text.RegularExpressions.Regex]::Escape("C:\tools\flutter;"), 'C:\tools\flutter\flutter\bin;');
        [System.Environment]::SetEnvironmentVariable('Path', $machinePath, 'Machine')

        Write-Information "Corrigido a variavel de ambiente Flutter";
    }
}

function getUserPath () {
    $usrPath = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString();

    if($usrPath -eq $null){
        [System.Environment]::SetEnvironmentVariable('Path', 'C:\Tmp', 'User');
        $usrPath = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString();
    }

    return $usrPath;
}

function getMachinePath () {
    $machPath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()

    if($machPath -eq $null){
        [System.Environment]::SetEnvironmentVariable('Path', 'C:\Tmp', 'Machine');
        $machPath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
    }

    return $machPath;
}


Set-ExecutionPolicy Unrestricted -Scope CurrentUser
installChocolatey
createDevelopmentEnvironment

Read-Host -Prompt "Pressione [ENTER] para encerrar";