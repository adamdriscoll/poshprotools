[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$MainForm = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Button]$btnName = $null
[System.Windows.Forms.ProgressBar]$progress = $null
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$progress = (New-Object -TypeName System.Windows.Forms.ProgressBar)
$btnName = (New-Object -TypeName System.Windows.Forms.Button)
$MainForm.SuspendLayout()
#
#progress
#
$progress.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]12,[System.Int32]12))
$progress.Name = [string]'progress'
$progress.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]260,[System.Int32]23))
$progress.TabIndex = [System.Int32]0
#
#btnName
#
$btnName.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]71,[System.Int32]64))
$btnName.Name = [string]'btnName'
$btnName.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]142,[System.Int32]23))
$btnName.TabIndex = [System.Int32]1
$btnName.Text = [string]'Fill Progress Bar'
$btnName.UseVisualStyleBackColor = $true
$btnName.add_Click($btnName_Click)
#
#MainForm
#
$MainForm.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]284,[System.Int32]100))
$MainForm.Controls.Add($btnName)
$MainForm.Controls.Add($progress)
$MainForm.Name = [string]'MainForm'
$MainForm.Text = [string]'Test'
$MainForm.ResumeLayout($false)
Add-Member -InputObject $MainForm -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name btnName -Value $btnName -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name progress -Value $progress -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name button1 -Value $button1 -MemberType NoteProperty
}
. InitializeComponent
