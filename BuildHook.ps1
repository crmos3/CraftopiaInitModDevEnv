function scriptPath($path) {
    return Split-Path -Parent $path
}


function searchBepInExFiles($path) {
    return Get-ChildItem ($path + "\BepInEx\core") -File
}


function searchUnityFiles($path) {
    return Get-ChildItem ($path + "\Craftopia_Data\Managed") -File
}


function searchUnnecessaryFiles($path) {
    $bepInExFiles = searchBepInExFiles $path
    $unityFiles = searchUnityFiles $path
    return $bepInExFiles + $unityFiles
}


function searchOutputFiles($path, $arg) {
    $type = $arg[0]
    $solution = $arg[1]
    return Get-ChildItem ("$path\ModDev\$solution\bin\$type") -File
}


function selectCopyFiles($unnecesaryFiles, $outputFiles) {
    $copyFiles = @()
    :outputFile foreach($file in $outputFiles){
        if($file -match ".*dll"){
            foreach($ufile in $unnecesaryFiles){
                if($file.name -eq $ufile.name){
                   continue outputfile
                }
            }
            $copyFiles = $copyFiles + $file.name
        }
    }
    return $copyFiles
}


function copyFiles($copyFiles, $path, $arg){
    $type = $arg[0]
    $solution = $arg[1]
    $p = "$path\BepInEx\plugins\$solution"
    if(Test-Path $p){}
    else{
        New-Item $p -ItemType Directory | Out-Null
    }

    foreach($file in $copyFiles){
        $f = "$path\ModDev\$solution\bin\$type\$file"
        Copy-Item $f $p
    }
}


$path = scriptPath $MyInvocation.MyCommand.Path
$unnecesaryFiles = searchUnnecessaryFiles $path
$outputFiles = searchOutputFiles $path $args
$copyFiles = selectCopyFiles $unnecesaryFiles $outputFiles
copyFiles $copyFiles $path $args
