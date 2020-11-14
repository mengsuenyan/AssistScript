# usage: put the file in the root directory of git warehouse and run it.

$NOT_GIT_REPO = "NotGitRepository"
$UPD_FAILED = "UpdateFailed"
$LESS_TIME = "OnlyUpdatedEveryHalfMonth"
$UPD_SUCESS = "UpdateSucess"

$OriginalPath = $PSScriptRoot

$Repositories = (Get-ChildItem -Path $OriginalPath) | Sort-Object -Property LastWriteTime
$Today = Get-Date

$IsUpd = @{}
foreach ($x in (1..1)) {
	foreach ($repo in $Repositories) {
		$path = $repo.FullName

		if ($path -in $IsUpd) {
			continue
		}

        if (($Today - $repo.LastWriteTime).Days -lt 15) {
            $IsUpd[$path] = $LESS_TIME
            continue
        }

	    if (-not ((Get-ChildItem -Path $path -Force) -match ".*\.git$")) {
			$IsUpd[$path]=$NOT_GIT_REPO
		    continue
	    }

		Set-Location -Path $path
	    Get-Location | Out-Host
		$out= $(git pull) *>&1

		if (-not ($out -match ".*fatal.*")) {
			$IsUpd[$path]=$UPD_SUCESS
		}
    
		$out | Out-Host
		Set-Location -Path $OriginalPath
	}

	if ($IsUpd.Count -ge $Repositories.Length) {
		break
	}
}

foreach ($repo in $Repositories) {
	$path = $repo.FullName
	if ($IsUpd[$path] -eq $UPD_SUCESS) {
		Write-Host $repo,">",$UPD_SUCESS -ForegroundColor Green
	} elseif ($IsUpd[$path] -eq $NOT_GIT_REPO) {
		Write-Host $repo,">",$NOT_GIT_REPO -ForegroundColor White
	} elseif ($IsUpd[$path] -eq $LESS_TIME) {
		Write-Host $repo,">",$LESS_TIME -ForegroundColor Yellow
    } else {
		Write-Host $repo,">",$UPD_FAILED -ForegroundColor Red
    }
}

Set-Location $OriginalPath
Read-Host
