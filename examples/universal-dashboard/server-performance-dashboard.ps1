Start-Dashboard -Content { 
    New-Dashboard -Title "Server Performance Dashboard" -Color '#FF050F7F' -Content { 
        New-Row {
            New-Column -Size 6 -Content {
                New-Row {
                    New-Column -Size 12 -Content {
                        New-Table -Title "Server Information" -Headers @(" ", " ") -Endpoint {
                            @{
                                'Computer Name' = $env:COMPUTERNAME
                                'Operating System' = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
                                'Total Disk Space (C:)' = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'").Size / 1GB | ForEach-Object { "$([Math]::Round($_, 2)) GBs " }
                                'Free Disk Space (C:)' = (Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace / 1GB | ForEach-Object { "$([Math]::Round($_, 2)) GBs " }
                            }.GetEnumerator() | Out-TableData -Property @("Name", "Value")
                        }
                    }
                }
                New-Row {
                    New-Column -Size 3 -Content { 
                        New-Chart -Title "Memory by Process" -Type Doughnut -RefreshInterval 5 -Endpoint {
                            Get-Process | ForEach-Object { [PSCustomObject]@{ Name = $_.Name; WorkingSet = [Math]::Round($_.WorkingSet / 1MB, 2) }} |  Out-ChartData -DataProperty "WorkingSet" -LabelProperty Name
                        } -Options @{
                            legend = @{
                                display = $false
                            }
                        }
                    }
                    New-Column -Size 3 -Content { 
                        New-Chart -Title "CPU by Process" -Type Doughnut -RefreshInterval 5 -Endpoint {
                            Get-Process | ForEach-Object { [PSCustomObject]@{ Name = $_.Name; CPU = $_.CPU } } |  Out-ChartData -DataProperty "CPU" -LabelProperty Name
                        } -Options @{
                            legend = @{
                                display = $false
                            }
                        }
                    }
                    New-Column -Size 3 -Content { 
                        New-Chart -Title "Handle Count by Process" -Type Doughnut -RefreshInterval 5 -Endpoint {
                            Get-Process | Out-ChartData -DataProperty "HandleCount" -LabelProperty Name
                        } -Options @{
                            legend = @{
                                display = $false
                            }
                        }
                    }
                    New-Column -Size 3 -Content { 
                        New-Chart -Title "Threads by Process" -Type Doughnut -RefreshInterval 5 -Endpoint {
                            Get-Process | ForEach-Object { [PSCustomObject]@{ Name = $_.Name; Threads = $_.Threads.Count } } |  Out-ChartData -DataProperty "Threads" -LabelProperty Name
                        } -Options @{
                            legend = @{
                                display = $false
                            }
                        }
                    }
                }
                New-Row {
                    New-Column -Size 12 -Content {
                        New-Chart -Title "Disk Space by Drive" -Type Bar -AutoRefresh -Endpoint {
                            Get-CimInstance -ClassName Win32_LogicalDisk | ForEach-Object { 
                                    [PSCustomObject]@{ DeviceId = $_.DeviceID; 
                                                       Size = [Math]::Round($_.Size / 1GB, 2); 
                                                       FreeSpace = [Math]::Round($_.FreeSpace / 1GB, 2); } } | Out-ChartData -LabelProperty "DeviceID" -Dataset @(
                                New-ChartDataset -DataProperty "Size" -Label "Size" -BackgroundColor "#80962F23" -HoverBackgroundColor "#80962F23"
                                New-ChartDataset -DataProperty "FreeSpace" -Label "Free Space" -BackgroundColor "#8014558C" -HoverBackgroundColor "#8014558C"
                            )
                        }
                    }
                }
            }
            New-Column -Size 6 -Content {
                New-Row {
                    New-Column -Size 6 -Content { 
                        New-Monitor -Title "CPU (% processor time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -BackgroundColor '#80FF6B63' -BorderColor '#FFFF6B63'  -Endpoint {
						    try {
								Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-MonitorData
							}
                            catch {
								0 | Out-MonitorData
							}
                        } 
                    }
                    New-Column -Size 6 -Content { 
                        New-Monitor -Title "Memory (% in use)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -BackgroundColor '#8028E842' -BorderColor '#FF28E842'  -Endpoint {
							try {
								Get-Counter '\memory\% committed bytes in use' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-MonitorData
							}
                            catch {
								0 | Out-MonitorData
							}
                        } 
                    }
                }
                New-Row {
                    New-Column -Size 6 -Content { 
                        New-Monitor -Title "Network (IO Read Bytes/sec)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -BackgroundColor '#80E8611D' -BorderColor '#FFE8611D'  -Endpoint {
							try {
								Get-Counter '\Process(_Total)\IO Read Bytes/sec' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-MonitorData
							}
                            catch {
								0 | Out-MonitorData
							}
                        } 
                    }
                    New-Column -Size 6 -Content { 
                        New-Monitor -Title "Disk (% disk time)" -Type Line -DataPointHistory 20 -RefreshInterval 5 -BackgroundColor '#80E8611D' -BorderColor '#FFE8611D'  -Endpoint {
							try {
								Get-Counter '\physicaldisk(_total)\% disk time' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue | Out-MonitorData
							}
							catch {
								0 | Out-MonitorData
							}
                        } 
                    }
                }
                New-Row {
                    New-Column -Size 12 {
                        New-Grid -Title "Processes" -Headers @("Name", "ID", "Working Set", "CPU") -Properties @("Name", "Id", "WorkingSet", "CPU") -AutoRefresh -RefreshInterval 60 -Endpoint {
                            Get-Process | Out-GridData
                        }
                    }
                }
            }
        }
    }
}

 
