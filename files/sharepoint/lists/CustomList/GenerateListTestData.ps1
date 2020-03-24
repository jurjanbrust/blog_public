﻿# Copyright (C) www.jurjan.info - All Rights Reserved
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Script to create and fill a list with listitems. Usefull for detecting problems with listview-treshhold issues (> 5000 listitems).
# Note that listview-treshhold issues can be solved by using SharePoint indexed columns.
# Change this script to include other columns besides 'QuestionType'. 'QuestionType' is only implemented here to serve as an example.

# change the following three lines to your likings
$url = "http://yourdevelopmentsitecollection/"
$listName = "sometestlist"
$itemsToCreate = 5010

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
Add-PSSnapin Microsoft.SharePoint.PowerShell -EA SilentlyContinue
Add-Type -Path "$ScriptDir\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "$ScriptDir\Microsoft.SharePoint.Client.Runtime.dll"

# open the site
$clientContext = New-Object Microsoft.SharePoint.Client.ClientContext($url);
$web = $clientContext.Web;
$clientContext.Load($web)
$clientContext.ExecuteQuery()
Write-Host $web.Title $web.ServerRelativeUrl -ForegroundColor Red -BackgroundColor Yellow

# open the list, if no list is found it will create one
$list = $web.Lists.GetByTitle($listName);
$clientContext.Load($list)
try {
    $clientContext.ExecuteQuery()
    Write-Host "Opened list" $list.Title -ForegroundColor Red -BackgroundColor Yellow
} catch {
    Write-Host "No list found, creating a new one"
    $listCreateInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation;
    $listCreateInfo.Title = $listName; 
    $listCreateInfo.TemplateType = [Microsoft.SharePoint.Client.ListTemplateType]::GenericList
    $list = $web.Lists.Add($listCreateInfo)
    $list.Update(); 
    $clientContext.ExecuteQuery(); 

	# add some listfields for example purposes
	$a = $list.Fields.AddFieldAsXml("<Field Type='Choice' DisplayName='QuestionType'>
                            <CHOICES>
                                <CHOICE>Office 365</CHOICE>
                                <CHOICE>General</CHOICE>
                                <CHOICE>Email</CHOICE>
                                <CHOICE>OneDrive</CHOICE>
                                <CHOICE>SharePoint</CHOICE>
                                <CHOICE>Office Apps</CHOICE>
                                <CHOICE>Office Online</CHOICE>
                                <CHOICE>Other</CHOICE>
                            </CHOICES></Field>",$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
}

# random words used to create listitems
$words = "Lorem","Ipsum","Donald","Duck","Wine","Chees","Fruit","Garlic","Weather","Together","Car","Pizza"
$choices = "Office 365", "General", "Email", "SharePoint"

for($index = 1; $index -lt $itemsToCreate+1; $index++) {
    $randomText = $words | Get-Random -count 1
    $titleText = "$index $randomText"
    Write-Host "[$index/$itemsToCreate] Creating '$titleText'" -ForegroundColor Green -BackgroundColor Red

    $newListItem = $list.AddItem($itemCreateInfo)
    $newListItem["Title"] =  $titleText
    $newListItem["QuestionType"] = $choices | Get-Random -count 1
    $newListItem.Update()
	if($index % 100 -eq 0)
	{
		Write-Host $index
		$clientContext.ExecuteQuery()
	}
}
$clientContext.ExecuteQuery()
Write-Host "Done!" -ForegroundColor Green
