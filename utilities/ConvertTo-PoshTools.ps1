param(
[Parameter(Mandatory = $true, HelpMessage = "The path to the PSF file you want to convert.")]    
$FilePath,
[Parameter(HelpMessage = "The path to the folder where you would like the converted items to go.")] 
$OutputPath = '.\')
<#
    --- WORK IN PROGRESS ---
    Converts a PowerShell Studio PSF file into a PowerShell script suitable for PowerShell Pro Tools for Visual Studio. 

    After converting the PSF file, you need to add the PS1 and Designer.PS1 file to a PowerShell Project. 

    This is currently a manual process. Open the PSSProj in your favorite text editor. 

    In an ItemGroup node within the PSSProj, add the form scripts in the following format:

      <ItemGroup>
        <Compile Include="test.psf.designer.ps1">
            <SubType>Code</SubType>
            <DependentUpon>test.psf.ps1</DependentUpon>
        </Compile>
        <Compile Include="test.psf.ps1">
            <SubType>Form</SubType>
        </Compile>
    </ItemGroup>

    Make sure to replace the file name with your converted file.
#>

Add-Type -AssemblyName System.Windows.Forms

if (-not (Test-Path $FilePath)) {
    throw "File not found."
}

function Out-ObjectVariable {
    param($Node, $MainObject)

    foreach($childNode in $Node.Object) {
        Out-ObjectVariable $childNode

        if ($childNode.name -eq $MainObject.name)
        {
            continue
        }

        $type = $childNode.type.split(',')[0]
        "[$type]`$$($childNode.name) = `$null"
    }
}

function Out-ObjectCreation {
    param($Node, $MainObject)
    
        foreach($childNode in $Node.Object) {
            Out-ObjectCreation $childNode

            if ($childNode.name -eq $MainObject.name)
            {
                continue
            }

            $type = $childNode.type.split(',')[0]
            "`$$($childNode.name) = (New-Object -TypeName '$type')"
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

        if ($property.Reference -ne $null) {
            $value = "`$$($property.Reference.name)"
        }
        elseif ($propertyType.Name -eq "Boolean") {
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

function Get-MainObject {
    param($Xml)

    $Xml.File.Object | Where type -eq "System.Windows.Forms.Form, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
}

function Out-LoadMainObject {
    param($Xml)
    $MainNode = Get-MainObject $Xml

    "`$$($MainNode.name).ShowDialog()"
}

function Out-ObjectAddChildObjects {
    param($Xml)

    $MainNode = Get-MainObject $Xml
    
    Out-ObjectChildObject $MainNode
}

[xml]$Xml = Get-Content $FilePath

$MainObject = Get-MainObject $xml

$Script = Out-Assembly $Xml
$Script += "`$$($MainObject.name) = New-Object -TypeName '$($MainObject.type.split(',')[0])'"
$Script += Out-ObjectVariable $Xml.File $MainObject

$Script += "function InitializeComponent {`r`n"
$Script += Out-ObjectCreation $Xml.File $MainObject
$Script += "`$$($MainObject.name).SuspendLayout()`r`n"

$Script += Out-Object $Xml.File
$Script += Out-ObjectAddChildObjects $Xml
$Script += "`$$($MainObject.name).ResumeLayout(`$false) `r`n}`r`n. InitializeComponent"

$fi = New-Object System.IO.FileInfo -ArgumentList $FilePath
$Script | Out-File -FilePath (Join-Path $OutputPath ($fi.Name + ".designer.ps1" ))

$Script = Out-Code $Xml 
$Script += "`r`n. (Join-Path `$PSScriptRoot '$($fi.Name).designer.ps1')`r`n"
$Script += Out-LoadMainObject $Xml
$Script | Out-File -FilePath (Join-Path $OutputPath ($fi.Name + ".ps1" ))

Write-Host "Conversion complete: `r`n You need to update your PSSProj by adding the following to the contents via a text editor:"
Write-Host "<ItemGroup>
<Compile Include=`"$($fi.Name).designer.ps1')`">
    <SubType>Code</SubType>
    <DependentUpon>$($fi.Name + ".ps1")</DependentUpon>
</Compile>
<Compile Include=`"$($fi.Name + ".ps1")`">
    <SubType>Form</SubType>
</Compile>
</ItemGroup>"