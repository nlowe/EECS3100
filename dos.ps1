function Build-Project{
    [CmdletBinding()]
    Param(
        [Parameter(Position=0)]
        [string] $ProjectPath = '.',
        [string] $FileName = 'program.asm',
        [string] $ObjectFile = 'program.obj',
        [string] $OutputFile = 'program.exe',
        [string] $LinkTo = ''
    )

    $linker = Join-Path -Path (Split-Path -Parent $global:masm) -ChildPath "LINK.EXE"

    Push-Location $ProjectPath

    Invoke-Expression "$global:masm /Zi /Zd $FileName,$ObjectFile"
    Invoke-Expression "&$linker --% /CODEVIEW $ObjectFile,$OutputFile,$OutputFile.map,$LinkTo,,"
    
    Pop-Location
}

function Find-MASM{
    $masm = (Get-Command -Name "MASM.EXE" -ErrorAction SilentlyContinue).Path

    if($masm -eq $null){
        # Now look in the current directory
        $masm = Test-Path -Path "MASM.EXE"

        if($masm -eq $null){
            throw "MASM could not be found. Ensure it's on your PATH or in your current directory"
        }
    }

    return $masm
}

$global:masm = Find-MASM
