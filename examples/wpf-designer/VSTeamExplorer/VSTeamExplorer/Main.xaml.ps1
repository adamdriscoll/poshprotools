function Add-ControlVariables {	New-Variable -Name 'txtPat' -Value $window.FindName('txtPat') -Scope 1 -Force
	New-Variable -Name 'txtAccount' -Value $window.FindName('txtAccount') -Scope 1 -Force
	New-Variable -Name 'lstFeatures' -Value $window.FindName('lstFeatures') -Scope 1 -Force
	New-Variable -Name 'btnLogin' -Value $window.FindName('btnLogin') -Scope 1 -Force
	New-Variable -Name 'txtOutput' -Value $window.FindName('txtOutput') -Scope 1 -Force	
	New-Variable -Name 'itemTeamInfo' -Value $window.FindName('itemTeamInfo') -Scope 1 -Force	
	New-Variable -Name 'itemProjects' -Value $window.FindName('itemProjects') -Scope 1 -Force	
}

function Load-Xaml {
	[xml]$xaml = Get-Content -Path $PSScriptRoot\Main.xaml
	$manager = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xaml.NameTable
	$manager.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
	$xaml.SelectNodes("//*[@x:Name='btnLogin']", $manager)[0].RemoveAttribute('Click')
	$xaml.SelectNodes("//*[@x:Name='itemTeamInfo']", $manager)[0].RemoveAttribute('Selected')
	$xaml.SelectNodes("//*[@x:Name='itemProjects']", $manager)[0].RemoveAttribute('Selected')
	$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
	Write-Host $xaml
	[Windows.Markup.XamlReader]::Load($xamlReader)
}
function Set-EventHandlers {
	$btnLogin.add_Click({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		btnLogin_Click($sender,$e)
	})
	$itemTeamInfo.add_Selected({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		teamInfoSelected($sender,$e)
	})
	$itemProjects.add_Selected({
		param([System.Object]$sender,[System.Windows.RoutedEventArgs]$e)
		projectsSelected($sender,$e)
	})
}

$window = Load-Xaml
Add-ControlVariables
Set-EventHandlers

# Import out functions into this script
. "$PSScriptRoot\VSFunctions.ps1"

#
#	Triggered when clicking the login button
#
function btnLogin_Click
{
	param($sender, $e)

	try {
		Login -Account $txtAccount.Text -Token $txtPat.Password
		$lstFeatures.IsEnabled = $true
	}
	catch [Exception] {
		Write-Error	$_
	}
}

#
#	Triggered when selecting team info
#
function teamInfoSelected
{
	param($sender, $e)

	$TeamInfo = GetInfo

	$txtOutput.AppendText($TeamInfo)
}

#
#	Triggered when selecting Projects
#
function projectsSelected
{
	param($sender, $e)

	$Projects = GetProjects

	$txtOutput.AppendText($Projects)
}


$window.ShowDialog()