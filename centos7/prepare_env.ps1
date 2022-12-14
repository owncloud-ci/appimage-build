# set default error actions
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$PSNativeCommandUseErrorActionPreference = $true;

# get the devtoolset env
$env2 = $($(bash -c "source /usr/local/bin/prepare_env.sh && printenv --null") | Out-String) -Split "`0"

# clean current env
Get-ChildItem env: | ForEach-Object {
    Remove-Item ("ENV:{0}" -f ${_}.Name)
}
# apply env2
foreach($_ in $env2) {
    if ($_ -match "=") {
        $v = $_.split("=", 2)
        set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
    }
}
