$wp = $PSScriptRoot
Set-Location $wp

$crpathsarr = @(
'https://github.com/filecoin-project/venus.git',
'https://github.com/filecoin-project/specs.git',
'https://github.com/filecoin-project/FIPs.git',
'https://github.com/filecoin-project/rust-fil-secp256k1.git',
'https://github.com/filecoin-project/cpp-filecoin.git',
'https://github.com/filecoin-project/go-data-transfer.git',
'https://github.com/filecoin-project/tpm.git',
'https://github.com/filecoin-project/neptune.git',
'https://github.com/filecoin-project/lotus.git',
'https://github.com/filecoin-project/slate.git',
'https://github.com/filecoin-project/specs-actors.git',
'https://github.com/filecoin-project/sentinel-visor.git',
'https://github.com/filecoin-project/ent.git',
'https://github.com/filecoin-project/filecoin-docs.git',
'https://github.com/filecoin-project/rust-fil-proofs.git',
'https://github.com/filecoin-project/rust-gpu-tools.git',
'https://github.com/filecoin-project/filecoin-ffi.git',
'https://github.com/filecoin-project/go-fil-markets.git',
'https://github.com/filecoin-project/statediff.git',
'https://github.com/filecoin-project/go-amt-ipld.git',
'https://github.com/filecoin-project/bellperson.git',
'https://github.com/filecoin-project/oni.git',
'https://github.com/filecoin-project/rust-filecoin-proofs-api.git',
'https://github.com/filecoin-project/go-jsonrpc.git',
'https://github.com/filecoin-project/filecoin-discover-validator.git',
'https://github.com/filecoin-project/devgrants.git',
'https://github.com/filecoin-project/go-bitfield.git',
'https://github.com/filecoin-project/go-hamt-ipld.git',
'https://github.com/filecoin-project/rust-fil-nse-gpu.git',
'https://github.com/filecoin-project/network-info.git',
'https://github.com/filecoin-project/sentinel-drone.git',
'https://github.com/filecoin-project/merkletree.git',
'https://github.com/filecoin-project/phase2.git',
'https://github.com/filecoin-project/paired.git',
'https://github.com/filecoin-project/blstrs.git',
'https://github.com/filecoin-project/mapr.git',
'https://github.com/filecoin-project/blst.git',
'https://github.com/filecoin-project/bls-signatures.git',
'https://github.com/filecoin-project/rust-filbase.git',
'https://github.com/filecoin-project/rust-sha2ni.git'
)
$crpathsarr = $crpathsarr | Select-Object -Unique
$crpaths = @{}
foreach ($idx in 0..($crpathsarr.Length-1)) {
$crpaths.Add($idx, $crpathsarr[$idx])
}

function git-process {
    param(
        [Parameter(Mandatory=$true)]
        [string] $app,
        [Parameter(Mandatory=$true)]
        [string] $cmd
    )

    $process = new-object System.Diagnostics.Process
    $process.StartInfo.FileName = $app
    $process.StartInfo.Arguments = $cmd
    $process.StartInfo.UseShellExecute = 0
    $process.StartInfo.RedirectStandardInput = 0
    $process.StartInfo.RedirectStandardOutput = 1
    $process.StartInfo.RedirectStandardError = 1
    $process.StartInfo.CreateNoWindow = 1
    $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden;
    $process.Start()
    $error_info = $process.StandardError.ReadToEnd()
    $result = $process.StandardOutput.ReadToEnd()
	$result
    $error_info
}


while ($true) {
    $cr = (Get-ChildItem -Path $wp -Directory).BaseName
    $isneedbreak = $true
	Out-Default -Input $crpaths
    $crhash = $crpaths.Clone()

    foreach ($item in $crhash.GetEnumerator()) {
        $crpath = $item.value
        if ($crpath -match "https://github.com/.*\.git") {
            $name = $crpath.SubString($crpath.lastindexof('/') + 1, $crpath.lastindexof('.') - $crpath.lastindexof('/') - 1)
            if ($cr -notcontains $name) {
                Write-Host $crpath
                $info = git-process -app "git" -cmd "clone $crpath"
				Out-Default -Input $info
                if ($info -match 'not') {
                    $crpaths.Remove($item.key)
                } elseif ((-not ($info -match 'fatal|error')) -and ($info -match 'Cloning into')) {
                    $crpaths.Remove($item.key)
				}
                Start-Sleep -Seconds 60
                $isneedbreak = $false
            } else {
				$crpaths.Remove($item.key)
			}
        }
    }

    if ($isneedbreak) {
        break
    }
}

Read-Host "Enter any key exist"
