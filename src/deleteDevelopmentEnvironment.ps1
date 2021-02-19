
function uninstallChocolatey () {
        
    if (!$env:ChocolateyInstall) {
        Write-Warning "The ChocolateyInstall environment variable was not found. `n Chocolatey is not detected as installed. Nothing to do"
        return
    }
    if (!(Test-Path "$env:ChocolateyInstall")) {
        Write-Warning "Chocolatey installation not detected at '$env:ChocolateyInstall'. `n Nothing to do."
        return
    }
      
    $userPath = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
    $machinePath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
      
    # User PATH:
    $userPath | Out-File "C:\PATH_backups_ChocolateyUninstall.txt" -Encoding UTF8 -Force

    # Machine PATH:
    $machinePath | Out-File "C:\PATH_backups_ChocolateyUninstall.txt" -Append -Encoding UTF8 -Force
      
    if ($userPath -like "*$env:ChocolateyInstall*") {
        Write-Output "Chocolatey Install location found in User Path. Removing..."
        # WARNING: This could cause issues after reboot where nothing is
        # found if something goes wrong. In that case, look at the backed up
        # files for PATH.
        [System.Text.RegularExpressions.Regex]::Replace($userPath, [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | ForEach-Object { [System.Environment]::SetEnvironmentVariable('PATH', $_.Replace(";;", ";"), 'User') }
    }
      
    if ($machinePath -like "*$env:ChocolateyInstall*") {
        Write-Output "Chocolatey Install location found in Machine Path. Removing..."
        # WARNING: This could cause issues after reboot where nothing is
        # found if something goes wrong. In that case, look at the backed up
        # files for PATH.
        [System.Text.RegularExpressions.Regex]::Replace($machinePath, [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyInstall\bin") + '(?>;)?', '', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase) | ForEach-Object { [System.Environment]::SetEnvironmentVariable('PATH', $_.Replace(";;", ";"), 'Machine') }
    }
      
    # Adapt for any services running in subfolders of ChocolateyInstall
    $agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue
    if ($agentService -and $agentService.Status -eq 'Running') { $agentService.Stop() }
    # TODO: add other services here
      
    # delete the contents (remove -WhatIf to actually remove)
    Remove-Item -Recurse -Force "$env:ChocolateyInstall"
      
    [System.Environment]::SetEnvironmentVariable("ChocolateyInstall", $null, 'User')
    [System.Environment]::SetEnvironmentVariable("ChocolateyInstall", $null, 'Machine')
    [System.Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate", $null, 'User')
    [System.Environment]::SetEnvironmentVariable("ChocolateyLastPathUpdate", $null, 'Machine')

    if ($env:ChocolateyToolsLocation) { 
        Remove-Item -Recurse -Force "$env:ChocolateyToolsLocation"
    }

    [System.Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $null, 'User')
    [System.Environment]::SetEnvironmentVariable("ChocolateyToolsLocation", $null, 'Machine')
      
    Write-Output "Chocolatey uninstall succeeded."
}

function destroyDevelopmentEnvironment () {
    npm uninstall @angular/cli;
    Write-Information "Angular CLI desinstalado com sucesso!";
    
    $tools = @( "openjdk8", "maven", "nodejs-lts", "git", "dotnetcore-sdk", "dart-sdk", "flutter", "vscode", "AndroidStudio", "android-sdk", "docker", "postman", "gh");
    foreach ($tool in $tools) {
        choco uninstall $tool -y --accept-license -f;
        Write-Information "${tool} desinstalado com sucesso!";
    }
}

function clearUserCustomEnvironmentVariables ($tool) {
    $userPath = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
    $userPath = [System.Text.RegularExpressions.Regex]::Replace($userPath, [System.Text.RegularExpressions.Regex]::Escape("$env:ChocolateyToolsLocation") + '(?>;)?', '');
    $userPath = [System.Text.RegularExpressions.Regex]::Replace($userPath, [System.Text.RegularExpressions.Regex]::Escape("C:\Android") + '(?>;)?', '');
    [System.Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')
}
  
function clearMachineCustomEnvironmentVariables ($tool) {
    $machinePath = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Control\Session Manager\Environment\').GetValue('PATH', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames).ToString()
    [System.Environment]::SetEnvironmentVariable('Path', $machinePath, [System.EnvironmentVariableTarget]::Machine);
}    

destroyDevelopmentEnvironment;
uninstallChocolatey;
Read-Host -Prompt "Pressione [ENTER] para encerrar"; 
