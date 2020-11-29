function getCurrentDirectory($scriptPath) {
    return Split-Path -Parent $scriptPath
}


function IsCrafiopiaDirectory($currentDirectory) {
    $pattern = '.*Craftopia'
    return $currentDirectory -match $pattern
}


function verifyCurrentDirectory($currentDirectory) {
    if (IsCrafiopiaDirectory $currentDirectory) {
        Write-Output "Current directory is Craftopia directory"
    }
    else {
        Write-Error "Current directory is not Craftopia directory"
        exit
    }
}


function existBepInEx() {
    return Test-Path .\BepInEx
}


function downloadBepInEx() {
    $fileName = ".\BepInEx.zip"
    Invoke-WebRequest https://github.com/BepInEx/BepInEx/releases/download/v5.4.3/BepInEx_x64_5.4.3.0.zip -OutFile $fileName
    return $fileName
}


function expandZip($file, $output) {
    Expand-Archive -Path .\BepInEx.zip -DestinationPath $output -Force
}

function setupConfig {
    $configFile = ".\BepInEx\config\BepInEx.cfg"
    $(Get-Content $configFile) -replace "LogConsoleToUnityLog = false", "LogConsoleToUnityLog = true" | Out-File -Encoding UTF8 ".\BepInEx\config\BepInEx.cfg"
    
    #不要なところまで書き換える可能性がある BepInEx v5.4.3では正しく動作する
    $(Get-Content $configFile) -replace "Enabled = false", "Enabled = true" | Out-File -Encoding UTF8 ".\BepInEx\config\BepInEx.cfg"
}


function verifyBepInEx() {
    if (existBepInEx) {
        Write-Output "BepInEx Exist"
        $ans = Read-Host "Setup BepInEx config? [y/n]"
        if ($ans -eq "y"){
            setupConfig
        }
    }
    else {
        Write-Output "BepInEx does not Exist"
        Write-Output "Downloading BepInEx"
        $fileName = downloadBepInEx
        Write-Output "Download done"
        Write-Output "Expanding Zip"
        expandZip $fileName "./"
        Write-Output "Expand done"
        Remove-Item $fileName
        Start-Process -FilePath ".\Craftopia.exe"
        Write-Output "Initializing BepInEx. Please wait 90 seconds"
        Start-Sleep -s 90
        $pro = Get-process Craftopia
        if ( $null -ne $pro ) {
            Stop-process -name Craftopia
        }
        setupConfig
        Write-Output "Initialize BepInEx complete"
    }
}


function existParentFolder {
    return Test-Path .\ModDev
}


function createFolder($name) {
    if (Test-Path $name) {
        $err = "Folder " + $name + " already exists"
        Write-Error $err
        exit
    }
    New-Item $name -ItemType Directory | Out-Null
}


function getModName {
    return Read-Host "Input mod name"
}

function craftopiaDependencies {
    $depedencies = ""
    $files = Get-ChildItem (".\Craftopia_Data\Managed") -File
    foreach($file in $files){
        if($file.name -match ".*AD_.*dll*"){
            $name = $file.name.Substring(0, $file.name.Length - 4)
            $filename = $file.name
            $format = @"
        <Reference Include="$name">
            <HintPath>..\..\Craftopia_Data\Managed\$fileName</HintPath>
        </Reference>

"@
            $depedencies = $depedencies + $format
        }
    }
    return $depedencies
}


function createSln($name) {
    $guid1 = New-Guid
    $guid2 = New-Guid
    $guid3 = New-Guid
    $slnFormat = @"
    
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 16
VisualStudioVersion = 16.0.30413.136
MinimumVisualStudioVersion = 10.0.40219.1
Project("{$guid1}") = "$name", "$name.csproj", "{$guid2}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{$guid2}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{$guid2}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{$guid2}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{$guid2}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
	GlobalSection(SolutionProperties) = preSolution
		HideSolutionNode = FALSE
	EndGlobalSection
	GlobalSection(ExtensibilityGlobals) = postSolution
		SolutionGuid = {$guid3}
	EndGlobalSection
EndGlobal

"@

    Out-File -InputObject $slnFormat -FilePath (".\ModDev\" + $modName + "\" + $modName + ".sln")
    return $guid2
}


function createCsproj($name, $craftopiaDependencies) {
    $csprojFormat = @"
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <Import Project="`$(MSBuildExtensionsPath)\`$(MSBuildToolsVersion)\Microsoft.Common.props" Condition="Exists('`$(MSBuildExtensionsPath)\`$(MSBuildToolsVersion)\Microsoft.Common.props')" />
    <PropertyGroup>
        <Configuration Condition=" '`$(Configuration)' == '' ">Debug</Configuration>
        <Platform Condition=" '`$(Platform)' == '' ">AnyCPU</Platform>
        <ProjectGuid>14933d1a-7cb3-4711-945a-218ee7699593</ProjectGuid>
        <OutputType>Library</OutputType>
        <AppDesignerFolder>Properties</AppDesignerFolder>
        <RootNamespace>$name</RootNamespace>
        <AssemblyName>$name</AssemblyName>
        <TargetFrameworkVersion>v4.7.2</TargetFrameworkVersion>
        <FileAlignment>512</FileAlignment>
        <Deterministic>true</Deterministic>
    </PropertyGroup>
    <PropertyGroup Condition=" '`$(Configuration)|`$(Platform)' == 'Debug|AnyCPU' ">
        <DebugSymbols>true</DebugSymbols>
        <DebugType>full</DebugType>
        <Optimize>false</Optimize>
        <OutputPath>bin\Debug\</OutputPath>
        <DefineConstants>DEBUG;TRACE</DefineConstants>
        <ErrorReport>prompt</ErrorReport>
        <WarningLevel>4</WarningLevel>
    </PropertyGroup>
    <PropertyGroup Condition=" '`$(Configuration)|`$(Platform)' == 'Release|AnyCPU' ">
        <DebugType>pdbonly</DebugType>
        <Optimize>true</Optimize>
        <OutputPath>bin\Release\</OutputPath>
        <DefineConstants>TRACE</DefineConstants>
        <ErrorReport>prompt</ErrorReport>
        <WarningLevel>4</WarningLevel>
    </PropertyGroup>
    <ItemGroup>
        <Reference Include="0Harmony">
            <HintPath>..\..\BepInEx\core\0Harmony.dll</HintPath>
        </Reference>
        <Reference Include="BepInEx">
            <HintPath>..\..\BepInEx\core\BepInEx.dll</HintPath>
        </Reference>
        <Reference Include="UnityEngine">
            <HintPath>..\..\Craftopia_Data\Managed\UnityEngine.dll</HintPath>
        </Reference>
        <Reference Include="UnityEngine.CoreModule">
            <HintPath>..\..\Craftopia_Data\Managed\UnityEngine.CoreModule.dll</HintPath>
        </Reference>
        $craftopiaDependencies
        <Reference Include="System"/>
        
        <Reference Include="System.Core"/>
        <Reference Include="System.Xml.Linq"/>
        <Reference Include="System.Data.DataSetExtensions"/>


        <Reference Include="Microsoft.CSharp"/>

        <Reference Include="System.Data"/>
        
        <Reference Include="System.Net.Http"/>
        
        <Reference Include="System.Xml"/>
    </ItemGroup>
    <ItemGroup>
        <Compile Include="Patcher.cs" />
        <Compile Include="Properties\AssemblyInfo.cs" />
    </ItemGroup>
    <Import Project="`$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
    <PropertyGroup>
        <PreBuildEvent>
        </PreBuildEvent>
    </PropertyGroup>
    <PropertyGroup>
        <PostBuildEvent>powershell ..\..\..\..\BuildHook.ps1 `$(ConfigurationName) `$(SolutionName) `$(ProjectName)</PostBuildEvent>
    </PropertyGroup>
</Project>
    
"@
    Out-File -InputObject $csprojFormat -FilePath (".\ModDev\" + $modName + "\" + $modName + ".csproj")
}

function createPatcher($name) {
    $patcherFormat = @"
using System;
using BepInEx;

namespace $name
{
    [BepInPlugin("com.example.$name", "$name", "1.0.0.0")]
    public class Patcher : BaseUnityPlugin
    {
        void Awake()
        {
            UnityEngine.Debug.Log("Hello, world!");
        }
    }
}
"@
    Out-File -InputObject $patcherFormat -FilePath (".\ModDev\" + $modName + "\Patcher.cs")
}   


function createAssemblyInfo($name, $guid) {
    $infoFormat = @"
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
[assembly: AssemblyTitle("hoge")]
[assembly: AssemblyDescription("")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("")]
[assembly: AssemblyProduct("hoge")]
[assembly: AssemblyCopyright("Copyright ©  2020")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]
[assembly: ComVisible(false)]
[assembly: Guid("$guid")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
"@

    createFolder (".\ModDev\" + $modName +"\Properties")
    Out-File -InputObject $infoFormat -FilePath (".\ModDev\" + $modName + "\Properties\AssemblyInfo.cs")
}


function createFiles($name, $dependencies) {
    $guid = createSln $name
    createCsproj $name $dependencies
    createPatcher $name
    createAssemblyInfo $name $guid
}


function createProject {
    $existParentFolder = existParentFolder
    if (!$existParentFolder) {
        createFolder .\ModDev
    }
    $dependencies = craftopiaDependencies
    $modName = getModName
    createFolder (".\ModDev\" + $modName)
    createFiles $modName $dependencies
    Write-Output "Created project"
}


$currentDirectory = getCurrentDirectory $MyInvocation.MyCommand.Path
verifyCurrentDirectory $currentDirectory 
verifyBepInEx
createProject
