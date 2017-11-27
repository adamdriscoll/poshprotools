param($FilePath = 'C:\users\adam\Desktop\test.psf', $OutputPath = '.\test.ps1')
<#
    --- WORK IN PROGRESS ---
    Converts a PowerShell Studio PSF file into a PowerShell script suitable for PowerShell Pro Tools for Visual Studio. 
#>


if (-not (Test-Path $FilePath)) {
    throw "File not found."
}

function Out-ObjectVariable {
    param($Node)

    foreach($childNode in $Node.Object) {
        Out-ObjectVariable $childNode

        "`$$($childNode.name) = New-Object -TypeName '$($childNode.type)'"
    }
}

function Get-PropertyType {
    param($TypeName, $PropertyName)

    [System.Windows.Forms.Form].Assembly.GetType($TypeName.Split(",")[0]).GetProperty($PropertyName).PropertyType
}

function Out-ObjectProperty {
    param($Node) 

    if ($node.Property -eq $null) {
        return
    }

    foreach($property in $node.Property | Where extended -ne $true) {
        $value = "'$($property.innerText)'"

        $PropertyType = Get-PropertyType -TypeName $Node.type -PropertyName $property.name

        if ($propertyType.Name -eq "Boolean") {
            $value = "`$$($property.innerText)"
        }
        elseif ($propertyType.Name -eq "String") {
            $value = "'$($property.innerText)'"
        }
        elseif ($propertyType.FullName -eq "System.Drawing.Font") {
            $parts = $property.InnerText.Split(",")

            $value =  "New-Object -TypeName '$($PropertyType.FullName)' -ArgumentList @('$($parts[0])', $($parts[1].Trim('pt')))"
        }
        elseif ($propertyType.FullName -eq "System.Drawing.Color") {
            $value =  "[System.Drawing.Color]::FromArgb($($property.InnerText))"
        }
        elseif ($propertyType.IsEnum) {
            $value = ($property.innerText -split ',' | ForEach-Object { "[$($propertyType.FullName)]::$($_.Trim())" }) -join ' -bor '
        }
        elseif (-not $PropertyType.IsPrimitive) {
            $value = "New-Object -TypeName '$($PropertyType.FullName)' -ArgumentList @($($property.innerText))"
        } elseif ($PropertyType.IsPrimitive) {
            $value = $Property.innerText
        }   

        if ($PropertyType.IsArray) {
            $value = "@($value)"
        }

        "`$$($Node.name).$($property.name) = $value "
    }
}


function Out-ObjectChildObject {
    param($Node) 

    foreach($childObject in $node.Object) {

        Out-ObjectChildObject $childObject

        "`$$($Node.name).$($Node.children).Add(`$$($childObject.name))"
    }
}

function Out-ObjectEvent {
    param($Node) 

    foreach($event in $node.Event) {
        "`$$($Node.name).add_$($event.name)(`$$($event.innerText))"
    }
}

function Out-Object {
    param($Node)

    foreach($childNode in $Node.Object) {
        Out-Object $childNode
        Out-ObjectProperty $childNode 
        Out-ObjectEvent $childNode
    }
}

function Out-Assembly {
    param($Xml)

    foreach($assembly in $Xml.File.Assemblies.Assembly) {
        "[void][System.Reflection.Assembly]::Load('$($assembly)')"
    }
}

function Out-Code {
    param($Xml)

    $Xml.File.Code.'#cdata-section'
}
function Out-LoadMainObject {
    param($Xml)

    $MainNode = $Xml.File.Object | Where type -eq "System.Windows.Forms.Form, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"

    Out-ObjectChildObject $MainNode

    "`$$($MainNode.name).ShowDialog()"
}

[xml]$Xml = Get-Content $FilePath
$Script = Out-Assembly $Xml
$Script += Out-ObjectVariable $Xml.File
$Script += Out-Code $Xml 
$Script += Out-Object $Xml.File
$Script += Out-LoadMainObject $Xml


$Script | Out-File -FilePath $OutputPath





