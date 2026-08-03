# 다운로드 디렉터리 생성
$imgDir = "static/images/coupang"
$frameDir = "static/frames"
New-Item -ItemType Directory -Force -Path $imgDir | Out-Null
New-Item -ItemType Directory -Force -Path $frameDir | Out-Null

# Coupang 이미지 다운로드 (원본 URL이 만료/차단될 수 있음)
$urls = @(
  "https://ads-partners.coupang.com/image1/w4ZWhc2GJglwNgNCwxBSImkA06bFJ1Z0MqosKENNlNkliUG9lagzGKt1yL_PQkK1_7yT6Y09Y5ww1OkorF_W77HfyspahqVgPNdiyTzoWO_ecVX6Zxr5UfamYpr7s1K5DwcIKhyFE6tzrXyeHvtMCrPDBYH8YMb4ojPFhyu2CHt2r2rDDXpgQgBQD4bghqTiPHSIWXnWF5VICzYOWd0ee66ya7Oh5JH19Hu_Hz1Ke6IISoG_GMAg0ZW4XVy0TjtFlNAtxQmE7mQ5qCvlsXfHoxW6e25l-bhM86GbK-7gPKTAQ6U39QP0p67YXIqScZ5oILmoOxDk",
  "https://ads-partners.coupang.com/image1/m9KzifAkA3t0ioyBm-WLf6cBVMeu1IVPYg4pn6RU8zbVBS7sneI9B9-PIBRJCY9XpVW_HehOce43WjgBBIpS0zGTeTFxacf9dxYwnTMW0dVCXXKdbvZaOcOvWUpsZF9Wi0F2U4f4elzl9OswiJci-vFeWm3GrT8oSFI8I3zxN9WVCu-q2TaZQNrKIvahpCMBwtlPZGltqlncWuoUPmDRiuH9kQ7qyLlL-cp9dic6kuVkFM4CiOeu-DkJZErvvHER58sMem6GngwzcRfqdn22JIibHaNPgTiK-NBC1-iYDQLMojUHa6ELv06ygjtvguoV3ZBJKic="
)

for ($i = 0; $i -lt $urls.Count; $i++) {
  $url = $urls[$i]
  $out = Join-Path $imgDir ("image{0}.jpg" -f ($i+1))
  try {
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -ErrorAction Stop
    Write-Host "Downloaded: $out"
  } catch {
    Write-Warning "Failed to download $url : $_"
  }
}

# 프레임 파일은 이미 호스팅되어 있다면 도메인 치환을 시도하거나 직접 다운로드
$frames = @(
  @{ url = 'https://kjh15923.github.io/shopping-short/frames/2026-08-02-4-actual.jpg'; out = Join-Path $frameDir '2026-08-02-4-actual.jpg' },
  @{ url = 'https://kjh15923.github.io/shopping-short/frames/2026-07-31-2.jpg'; out = Join-Path $frameDir '2026-07-31-2.jpg' }
)

foreach ($f in $frames) {
  # 도메인 변경이 적용돼 있다면 dailyshort6로 시도
  $alt = $f.url -replace 'kjh15923.github.io','dailyshort6.github.io'
  try {
    Invoke-WebRequest -Uri $alt -OutFile $f.out -UseBasicParsing -ErrorAction Stop
    Write-Host "Downloaded frame from alt domain: $alt -> $($f.out)"
    continue
  } catch {
    Write-Host "Alt domain failed, trying original: $($f.url)"
  }
  try {
    Invoke-WebRequest -Uri $f.url -OutFile $f.out -UseBasicParsing -ErrorAction Stop
    Write-Host "Downloaded frame: $($f.url) -> $($f.out)"
  } catch {
    Write-Warning "Failed to download frame $($f.url) : $_"
  }
}

# 워크스페이스 내 도메인 치환 (백업 권장)
Write-Host "Replacing 'kjh15923.github.io' -> 'dailyshort6.github.io' in .md, .json, .html, .js files (creating backups with .bak)"
Get-ChildItem -Recurse -Include *.md,*.json,*.html,*.js | ForEach-Object {
  $path = $_.FullName
  $bak = $path + '.bak'
  Copy-Item -Force -Path $path -Destination $bak
  (Get-Content $path) -replace 'kjh15923.github.io','dailyshort6.github.io' | Set-Content $path
}

Write-Host "완료: 이미지 다운로드 및 도메인 치환 시도 완료. 변경된 파일은 스테이징/커밋이 필요합니다."
