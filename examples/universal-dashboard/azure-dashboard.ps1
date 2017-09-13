$Colors = @{
    BackgroundColor = "#FF252525"
    FontColor = "#FFFFFFFF"
}

$NavBarLinks = @((New-Link -Text "<i class='material-icons' style='display:inline;padding-right:5px'>favorite_border</i> PowerShell Pro Tools" -Url "https://poshtools.com/buy-powershell-pro-tools/"),
                 (New-Link -Text "<i class='material-icons' style='display:inline;padding-right:5px'>description</i> Documentation" -Url "https://adamdriscoll.gitbooks.io/powershell-tools-documentation/content/powershell-pro-tools-documentation/universal-dashboard.html"))

Start-Dashboard -Content { 
    New-Dashboard -NavbarLinks $NavBarLinks -Title "PowerShell Pro Tools Universal Dashboard" -NavBarColor '#FF1c1c1c' -NavBarFontColor "#FF55b3ff" -BackgroundColor "#FF333333" -FontColor "#FFFFFFF" -Content { 
        New-Row {
            New-Column -Size 3 {
                New-Html -Markup "<div class='card' style='background: rgba(37, 37, 37, 1); color: rgba(255, 255, 255, 1)'><div class='card-content'><span class='card-title'>About Universal Dashboard</span><p>Universal Dashboard is a cross-platform PowerShell module used to design beautiful dashboards from any available dataset. Visit GitHub to see some example dashboards.</p></div><div class='card-action'><a href='https://www.github.com/adamdriscoll/poshprotools'>GitHub</a></div></div>"
            }
            New-Column -Size 3 {
                New-Monitor -Title "Users per second" -Type Line -DataPointHistory 20 -RefreshInterval 15 -ChartBackgroundColor '#5955FF90' -ChartBorderColor '#FF55FF90' @Colors -Endpoint {
                    Get-Random -Minimum 0 -Maximum 100 | Out-MonitorData
                } 
            }
            New-Column -Size 3 {
                New-Monitor -Title "Downloads per second" -Type Line -DataPointHistory 20 -RefreshInterval 5 -ChartBackgroundColor '#59FF681B' -ChartBorderColor '#FFFF681B' @Colors -Endpoint {
                    Get-Random -Minimum 0 -Maximum 10 | Out-MonitorData
                } 
            }
            New-Column -Size 3 {
                New-Monitor -Title "Tweets per second" -Type Line -DataPointHistory 20 -RefreshInterval 20 -ChartBackgroundColor '#595479FF' -ChartBorderColor '#FF5479FF' @Colors -Endpoint {
                    Get-Random -Minimum 0 -Maximum 10000 | Out-MonitorData
                } 
            }
        }
        New-Row {
            New-Column -Size 6 {
                New-Chart -Title "Feature by operating system" -Type Bar -AutoRefresh -RefreshInterval 7 @Colors -Endpoint {
                    $features = @();
                    $features += [PSCustomObject]@{ "OperatingSystem" = "Windows 10"; "FormsDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "WPFDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "UniversalDashboard" = (Get-Random -Minimum 10 -Maximum 10000) }
                    $features += [PSCustomObject]@{ "OperatingSystem" = "Windows 8"; "FormsDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "WPFDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "UniversalDashboard" = (Get-Random -Minimum 10 -Maximum 10000) }
                    $features += [PSCustomObject]@{ "OperatingSystem" = "Windows 7"; "FormsDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "WPFDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "UniversalDashboard" = (Get-Random -Minimum 10 -Maximum 10000) }
                    $features += [PSCustomObject]@{ "OperatingSystem" = "Ubuntu 16.04"; "FormsDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "WPFDesigner" = (Get-Random -Minimum 10 -Maximum 10000);  "UniversalDashboard" = (Get-Random -Minimum 10 -Maximum 10000) }
                    $features| Out-ChartData -LabelProperty "OperatingSystem" -Dataset @(
                        New-ChartDataset -DataProperty "FormsDesigner" -Label "Forms Designer" -BackgroundColor "#80962F23" -HoverBackgroundColor "#80962F23"
                        New-ChartDataset -DataProperty "WPFDesigner" -Label "WPF Designer" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                        New-ChartDataset -DataProperty "UniversalDashboard" -Label "Universal Dashboard" -BackgroundColor "#803AE8CE" -HoverBackgroundColor "#803AE8CE"
                    )
                }
            }
            New-Column -Size 6 {
                New-Grid -Title "Top GitHub Issues" @Colors -Headers @("ID", "Title", "Description", "Comments") -Properties @("ID", "Title", "Description", "Comments") -AutoRefresh -RefreshInterval 20 -Endpoint {
                    $issues = @();
                    $issues += [PSCustomObject]@{ "ID" = (Get-Random -Minimum 10 -Maximum 10000);  "Title" = "Product is too awesome...";  "Description" = "Universal Desktop is just too awesome."; Comments = (Get-Random -Minimum 10 -Maximum 10000) }
                    $issues += [PSCustomObject]@{ "ID" = (Get-Random -Minimum 10 -Maximum 10000);  "Title" = "Support for running on a PS4";  "Description" = "A dashboard on a PS4 would be pretty cool."; Comments = (Get-Random -Minimum 10 -Maximum 10000) }
                    $issues += [PSCustomObject]@{ "ID" = (Get-Random -Minimum 10 -Maximum 10000);  "Title" = "Bug in the flux capacitor";  "Description" = "The flux capacitor is constantly crashing."; Comments = (Get-Random -Minimum 10 -Maximum 10000) }
                    $issues += [PSCustomObject]@{ "ID" = (Get-Random -Minimum 10 -Maximum 10000);  "Title" = "Feature Request - Hypnotoad Widget";  "Description" = "Every dashboard needs more hypnotoad"; Comments = (Get-Random -Minimum 10 -Maximum 10000) }
                    
                    $issues | Out-GridData
                }
            }
        }
    }
} -Wait

 
