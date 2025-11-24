<#
leetcode_helper.ps1
Usage (called from batch file):
  powershell -NoProfile -ExecutionPolicy Bypass -File "path\to\leetcode_helper.ps1" "arg"
If no arg is passed, it will open a random free problem.

Notes:
- Storage file is now placed next to this script (in the project folder).
- $PSScriptRoot is used so it works whether run from anywhere.
#>

param(
    [string]$arg = ""
)

# Storage file for solved/seen IDs (saved in same folder as the PS1 file)
$storage = Join-Path $PSScriptRoot ".leetcode_progress.txt"
if (-not (Test-Path $storage)) { New-Item -Path $storage -ItemType File -Force | Out-Null }

function Add-ToStorage {
    param([string]$id)
    try {
        # Avoid adding empty lines
        if ($null -ne $id -and $id.Trim() -ne "") {
            Add-Content -Path $storage -Value $id
        }
    } catch {
        Write-Host "Warning: couldn't write to storage: $($_.Exception.Message)"
    }
}

function Get-AllProblems {
    try {
        # Force TLS 1.2 and a User-Agent to avoid possible remote rejection
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT) PowerShell Script" }
        $resp = Invoke-WebRequest -Uri 'https://leetcode.com/api/problems/all/' -Headers $headers -UseBasicParsing
        $json = $resp.Content | ConvertFrom-Json
        return $json.stat_status_pairs
    } catch {
        throw "Failed to fetch problems: $($_.Exception.Message)"
    }
}

function Open-ProblemBySlug {
    param([string]$slug, [string]$id = $null)
    if ($id) { Add-ToStorage $id }
    Start-Process ("https://leetcode.com/problems/$slug/")
}

function Open-Random {
    param([ScriptBlock]$filter)
    try {
        $problems = Get-AllProblems | Where-Object { $_.paid_only -eq $false }
        if ($filter) { $problems = $problems | Where-Object $filter }
        if ($null -eq $problems -or $problems.Count -eq 0) { Write-Host "❌ No matching free problems found."; return }
        $p = $problems | Get-Random
        $slug = $p.stat.question__title_slug
        $id = $p.stat.frontend_question_id
        Add-ToStorage $id
        Start-Process ("https://leetcode.com/problems/$slug/")
    } catch {
        Write-Host "❌ Something went wrong: $($_.Exception.Message)"
    }
}

function Open-Daily {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT) PowerShell Script" }
        $html = Invoke-WebRequest -Uri 'https://leetcode.com' -Headers $headers -UseBasicParsing
        $match = ($html.Links.href | Select-String -Pattern '/problems/[^/]+/' | Select-Object -First 1)
        if (-not $match) { Write-Host "❌ Couldn't find daily problem."; return }
        $slug = $match.Matches.Value -replace '/problems/','' -replace '/',''
        Start-Process ("https://leetcode.com/problems/$slug/")
    } catch {
        Write-Host "❌ Daily fetch failed: $($_.Exception.Message)"
    }
}

function Open-ById {
    param([int]$id)
    try {
        $p = Get-AllProblems | Where-Object { $_.stat.frontend_question_id -eq $id -and $_.paid_only -eq $false }
        if (-not $p) { Write-Host "❌ Paid or invalid problem ID."; return }
        $slug = $p.stat.question__title_slug
        Add-ToStorage $id
        Start-Process ("https://leetcode.com/problems/$slug/")
    } catch {
        Write-Host "❌ Lookup failed: $($_.Exception.Message)"
    }
}

function Open-BySlug {
    param([string]$slug)
    Start-Process ("https://leetcode.com/problems/$slug/")
}

function Open-Next {
    try {
        $done = @()
        if (Test-Path $storage) {
            $done = Get-Content $storage | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Select-Object -Unique
        }
        $free = Get-AllProblems | Where-Object { $_.paid_only -eq $false } | Sort-Object { [int]$_.stat.frontend_question_id }
        $next = $free | Where-Object { $done -notcontains ($_.stat.frontend_question_id | ForEach-Object { $_.ToString() }) } | Select-Object -First 1
        if (-not $next) { Write-Host "🎉 All free problems completed!"; return }
        $slug = $next.stat.question__title_slug
        $id = $next.stat.frontend_question_id
        Add-ToStorage $id
        Start-Process ("https://leetcode.com/problems/$slug/")
    } catch {
        Write-Host "❌ Next fetch failed: $($_.Exception.Message)"
    }
}

# Tag helper: maps simple names to LeetCode topic names
$tagMap = @{
    "dp" = "Dynamic Programming"
    "tree" = "Tree"
    "string" = "String"
    "graph" = "Graph"
    "array" = "Array"
    "sorting" = "Sorting"
    "greedy" = "Greedy"
    "backtracking" = "Backtracking"
}

function Open-ByTag {
    param([string]$tagKey)
    try {
        $tagName = $tagMap[$tagKey]
        if (-not $tagName) { Write-Host "Unknown tag: $tagKey"; return }
        $filter = { ($_.topic_tags.name -contains $tagName) }
        Open-Random -filter $filter
    } catch {
        Write-Host "❌ Tag search failed: $($_.Exception.Message)"
    }
}

# Extra convenience commands: stats and reset
function Show-Stats {
    if (-not (Test-Path $storage)) {
        Write-Host "No progress recorded yet. File not found at $storage"
        return
    }
    $ids = Get-Content $storage | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" } | Select-Object -Unique
    $count = ($ids | Measure-Object).Count
    Write-Host "Progress file: $storage"
    Write-Host "Visited / recorded problem IDs: $count"
    if ($count -gt 0) {
        Write-Host "Sample IDs:"
        $ids | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
    }
}

function Reset-Progress {
    Write-Host "Clearing progress file at: $storage"
    try {
        Clear-Content -Path $storage -ErrorAction Stop
        Write-Host "Progress reset."
    } catch {
        Write-Host "Failed to reset: $($_.Exception.Message)"
    }
}

# Difficulty mapping: easy=1, medium=2, hard=3
switch ($arg.ToLower()) {
    "" { Open-Random -filter $null; break }
    "random" { Open-Random -filter $null; break }
    "easy" { Open-Random -filter { $_.difficulty.level -eq 1 }; break }
    "medium" { Open-Random -filter { $_.difficulty.level -eq 2 }; break }
    "hard" { Open-Random -filter { $_.difficulty.level -eq 3 }; break }
    "daily" { Open-Daily; break }
    "75" { Start-Process 'https://leetcode.com/studyplan/leetcode-75/'; break }
    "next" { Open-Next; break }
    "stats" { Show-Stats; break }
    "reset" { Reset-Progress; break }
    default {
        if ($arg -match '^[0-9]+$') {
            Open-ById -id ([int]$arg)
        } elseif ($tagMap.ContainsKey($arg.ToLower())) {
            Open-ByTag -tagKey $arg.ToLower()
        } else {
            # treat as slug
            Open-BySlug -slug $arg
        }
    }
}