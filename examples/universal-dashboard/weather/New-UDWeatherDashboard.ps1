
<#PSScriptInfo

.VERSION 1.0

.GUID 6b0d1db5-1951-43d8-adb7-6f27cae9d643

.AUTHOR Adam Driscoll

.COMPANYNAME Ironman Software, LLC

.COPYRIGHT 

.TAGS UniversalDashboard

.LICENSEURI 

.PROJECTURI https://github.com/adamdriscoll/poshprotools

.ICONURI 

.EXTERNALMODULEDEPENDENCIES UniversalDashboard

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


.PRIVATEDATA 

#>

<# 

.DESCRIPTION 
 A weather dashboard for PowerShell Universal Dashboard. 

#> 
param($State, $City)

New-UDDashboard -Title "Weather" -Content {
    New-UDColumn -Endpoint {
        $WeatherResult = Invoke-RestMethod "https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20weather.forecast%20where%20woeid%20in%20(select%20woeid%20from%20geo.places(1)%20where%20text%3D%22$City%2C%20$State%22)&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
        $BoltCodes = @(0, 1, 2, 3, 4, 37, 38, 39, 45, 47)
        $RainCodes = @(11, 12, 40)
        $SnowFlakeCodes = @(5, 6, 7, 8 , 9, 10, 13, 14, 15, 16, 17, 18, 35, 41, 42, 43, 46)
        $SunCodes = @(31,32,33,34)
        $CloudCodes = @(20, 21, 26, 27, 28, 29, 30, 44)

        New-UDRow -Columns {
            New-UDColumn -Size 6 -Content {
                New-UDRow -Columns {
                    New-UDColumn -Size 12 -Content {
                        $description = $WeatherResult.query.results.channel.item.condition.text
                        $code = $WeatherResult.query.results.channel.item.condition.code

                        $Icon = "sun_o"

                        if ($BoltCodes -contains $code) {
                            $Icon = "bolt"
                        }
                        elseif ($SnowFlakeCodes -contains $code) {
                            $Icon = "snowflake_o"
                        }
                        elseif ($SunCodes -contains $code) {
                            $Icon = "sun_o"
                        }
                        elseif ($CloudCodes -contains $code) {
                            $Icon = "cloud"
                        }
                        elseif ($RainCodes -contains $code) {
                            $Icon = "tint"
                        }

                        New-UDCard -Title "Current Condition" -Text $description -TextSize Medium -TextAlignment Center -Watermark $icon
                    }
                }
                New-UDRow -Columns {
                    $currentTemp = $WeatherResult.query.results.channel.item.condition.temp

                    New-UDColumn -Size 12 -Content {
                        New-UDCard -Title "Current Temperature" -Text "$currentTemp F" -TextSize Medium -TextAlignment Center -Watermark thermometer_half
                    }
                }
            }
            New-UDColumn -Size 6 -Content {
                New-UDHtml -Markup "<iframe style='height: 50ch; width:100%; margin-top:10px' src=`"https://www.wunderground.com/fullscreenweather`"></iframe>"
            }
        }

        New-UDRow -Columns {
            foreach($item in $WeatherResult.query.results.channel.item.forecast | Select-Object -First 6) {
                $highTemp = $item.high
                $lowTemp = $item.low
                $description = $item.text
                $code = $item.code

                $Icon = "sun_o"

                if ($BoltCodes -contains $code) {
                    $Icon = "bolt"
                }
                elseif ($SnowFlakeCodes -contains $code) {
                    $Icon = "snowflake_o"
                }
                elseif ($SunCodes -contains $code) {
                    $Icon = "sun_o"
                }
                elseif ($CloudCodes -contains $code) {
                    $Icon = "cloud"
                }
                elseif ($RainCodes -contains $code) {
                    $Icon = "tint"
                }

                New-UDColumn -Size 2 -Content {
                    New-UDCard -Title $item.day -Text "High: $highTemp`r`nLow: $lowTemp`r`n$description" -TextSize Medium -TextAlignment left -Watermark $icon
                }
            }
        }
    }
}

