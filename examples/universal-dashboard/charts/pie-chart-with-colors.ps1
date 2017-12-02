<#
    Provides an example of a pie chart with colors.
#>

Import-Module UniversalDashboard

$Data = @(
    @{Animal="Frog";Count=10}
    @{Animal="Tiger";Count=1}
    @{Animal="Bat";Count=34}
    @{Animal="Fox";Count=20}
)

$Dashboard = New-UDDashboard -Title "Charts - Pie Colors" -Content {

    New-UDChart -Title "Pie Chart" -Type "Doughnut" -Endpoint {
        $Data | Out-UDChartData -LabelProperty "Animal"  -Dataset @(
            New-UDLineChartDataset -Label "Animals" -DataProperty Count -BackgroundColor @("#2C44E8", "#FF4239", "#6FFF37","#FF912D") -BorderColor @("#000000", "#000000", "#000000","#000000") -BorderWidth 1
        )
    } -Options @{cutoutPercentage = 0}
}

Start-UDDashboard -Dashboard $Dashboard -Port 8080