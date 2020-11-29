# CraftopiaInitModDevEnv

## Overview
This is a PowerShell script to build the Craftopia mod development environment.Specifically the following processes
* Installing BepInEx (If you already have BepInEx installed, it will be skipped)
* Setup BepInEx config
* Creating a Visual Studio solution (Including setting up dependencies and build events)

## Install
Place InitModDevEnv.ps1 and BuildHook.ps1 in the Craftopia folder.  
You need to set the proper script execution policy for the LocalUser in PowerShell.

## How to Use
Run InitModDevEnv.ps1 in PowerShell.  
If you do not have BepInEx installed, it will be downloaded automatically.During the installation of BepInEx, Craftopia will start, but wait until it quits automatically.  
BepInEx settings can be changed to output a log.If you have been using BepInEx as a mod user, please change the settings of BepInEx.  
Enter the name of the mod, and it will be set as Solution or solution etc.  
solution is created in Craftopia\\ModDev\\**Mod Name**\\. Do not move this solution because it will break the dependency.  
The Project included in this Solution has a BuildEvent set.Simply build the project and the mod will be deployed to Craftopia\\BepInEx\\plugins\\**Mod Name**\\.  
