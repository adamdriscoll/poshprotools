#Import the VSTeam module to connect to VSTS
Import-Module VSTeam

function Login {
	param($account, $token)

	Add-VSTeamAccount -Account $account -PersonalAccessToken  $token
}

function GetProjects() {
	Get-VSTeamProject | Out-String
}

function GetInfo() {
	Get-VSTeamInfo | Out-String
}


