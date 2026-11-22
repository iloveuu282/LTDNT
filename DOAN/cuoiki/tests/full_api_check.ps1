param([string]$ApiUrl='http://127.0.0.1:5081')
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Net.Http
$http=New-Object System.Net.Http.HttpClient
$http.Timeout=[TimeSpan]::FromSeconds(30)
$suffix=[Guid]::NewGuid().ToString('N')
$adminEmail="api.admin.$suffix@example.com"
$memberEmail="api.member.$suffix@example.com"
$otherEmail="api.other.$suffix@example.com"
$password='Check@123456'
$categoryIds=New-Object 'System.Collections.Generic.List[int]'
$surveyIds=New-Object 'System.Collections.Generic.List[int]'
$campaignIds=New-Object 'System.Collections.Generic.List[int]'
$paths=New-Object 'System.Collections.Generic.List[string]'
$checks=0

function Sql($query) {
    & sqlcmd -S '.\SQLEXPRESS' -E -C -b -d BusinessSurvey -Q $query | Out-Null
    if($LASTEXITCODE -ne 0){throw 'SQL failed'}
}
function Request($method,$path,$body,$token) {
    $message=New-Object System.Net.Http.HttpRequestMessage ([System.Net.Http.HttpMethod]::new($method)), "$ApiUrl/api/$path"
    if($token){$message.Headers.Authorization=[System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer',$token)}
    if($null -ne $body){
        if($path -match '^categories(/\d+)?$' -and $method -in @('POST','PUT')){
            $message.Content=[System.Net.Http.MultipartFormDataContent]::new()
            foreach($key in $body.Keys){$message.Content.Add([System.Net.Http.StringContent]::new([string]$body[$key],[Text.Encoding]::UTF8),$key)}
        }else{$message.Content=[System.Net.Http.StringContent]::new(($body|ConvertTo-Json -Depth 20),[Text.Encoding]::UTF8,'application/json')}
    }
    try{
        $response=$http.SendAsync($message).GetAwaiter().GetResult()
        $raw=$response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        $data=$null;try{$data=$raw|ConvertFrom-Json}catch{}
        $result=@{Code=[int]$response.StatusCode;Data=$data;Raw=$raw};$response.Dispose();return $result
    }finally{$message.Dispose()}
}
function Check($result,$expected,$label) {
    if($result.Code -ne $expected){throw "$label expected $expected got $($result.Code): $($result.Raw)"}
    $script:checks++;Write-Output "PASS $label ($expected)"
}
function Start-Post($path,$body,$token) {
    $message=[System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Post,"$ApiUrl/api/$path")
    $message.Headers.Authorization=[System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer',$token)
    $message.Content=[System.Net.Http.StringContent]::new(($body|ConvertTo-Json -Depth 20),[Text.Encoding]::UTF8,'application/json')
    return @{Message=$message;Task=$http.SendAsync($message)}
}
function Finish-Post($pending) {
    try{
        $response=$pending.Task.GetAwaiter().GetResult()
        $raw=$response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        $data=$null;try{$data=$raw|ConvertFrom-Json}catch{}
        $result=@{Code=[int]$response.StatusCode;Data=$data;Raw=$raw};$response.Dispose();return $result
    }finally{$pending.Message.Dispose()}
}
function Upload($id,$title,$categoryId,$questions,$token,$withImage=$true,$invalidImage=$false) {
    $method=if($id){'PUT'}else{'POST'}
    $path=if($id){"surveys/$id"}else{'surveys'}
    $message=[System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($method),"$ApiUrl/api/$path")
    $message.Headers.Authorization=[System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer',$token)
    $content=[System.Net.Http.MultipartFormDataContent]::new()
    $content.Add([System.Net.Http.StringContent]::new("$categoryId"),'categoryId')
    $content.Add([System.Net.Http.StringContent]::new($title,[Text.Encoding]::UTF8),'title')
    $content.Add([System.Net.Http.StringContent]::new('Survey API check',[Text.Encoding]::UTF8),'description')
    $content.Add([System.Net.Http.StringContent]::new((ConvertTo-Json -InputObject @($questions) -Depth 10),[Text.Encoding]::UTF8),'questionsJson')
    if($withImage){
        $image=[Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aOmsAAAAASUVORK5CYII=')
        if($invalidImage){$image=[Text.Encoding]::UTF8.GetBytes('Not an image')}
        $content.Add([System.Net.Http.ByteArrayContent]::new($image),'image','check.png')
    }
    $message.Content=$content
    try{
        $response=$http.SendAsync($message).GetAwaiter().GetResult();$raw=$response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        $data=$null;try{$data=$raw|ConvertFrom-Json}catch{}
        $result=@{Code=[int]$response.StatusCode;Data=$data;Raw=$raw};$response.Dispose();return $result
    }finally{$message.Dispose()}
}
function ImageStatus($path) {
    $response=$http.GetAsync("$ApiUrl$path").GetAwaiter().GetResult()
    $status=[int]$response.StatusCode;$response.Dispose();return @{Code=$status}
}
function UploadCategory($id,$name,$token,$invalid=$false,$remove=$false) {
    $method=if($id){'PUT'}else{'POST'}
    $path=if($id){"categories/$id"}else{'categories'}
    $message=[System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($method),"$ApiUrl/api/$path")
    $message.Headers.Authorization=[System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer',$token)
    $content=[System.Net.Http.MultipartFormDataContent]::new()
    $content.Add([System.Net.Http.StringContent]::new($name,[Text.Encoding]::UTF8),'categoryName')
    $content.Add([System.Net.Http.StringContent]::new('Category image check'),'description')
    $content.Add([System.Net.Http.StringContent]::new($remove.ToString().ToLowerInvariant()),'removeImage')
    if(!$remove){
        $image=[Convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aOmsAAAAASUVORK5CYII=')
        if($invalid){$image=[Text.Encoding]::UTF8.GetBytes('Not an image')}
        $content.Add([System.Net.Http.ByteArrayContent]::new($image),'image','category.png')
    }
    $message.Content=$content
    try{
        $response=$http.SendAsync($message).GetAwaiter().GetResult();$raw=$response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
        $data=$null;try{$data=$raw|ConvertFrom-Json}catch{}
        $result=@{Code=[int]$response.StatusCode;Data=$data;Raw=$raw};$response.Dispose();return $result
    }finally{$message.Dispose()}
}
function CategoryPath($id,$token) {
    return @((Request GET 'categories' $null $token).Data | Where-Object { $_.categoryId -eq $id })[0].imagePath
}
try{
    foreach($email in @($adminEmail,$memberEmail,$otherEmail)){
        Check (Request POST 'auth/register' @{fullName='API check';email=$email;password=$password;roleName='Admin'} '') 201 'Register'
    }
    Sql "UPDATE Members SET RoleId=(SELECT RoleId FROM Roles WHERE RoleName='Admin') WHERE Email='$adminEmail'"
    $admin=(Request POST 'auth/login' @{email=$adminEmail;password=$password} '').Data
    $member=(Request POST 'auth/login' @{email=$memberEmail;password=$password} '').Data
    $other=(Request POST 'auth/login' @{email=$otherEmail;password=$password} '').Data
    if($member.member.roleName -ne 'Member'){throw 'Register escalated role'}
    Check (Request POST 'categories' @{categoryName='Blocked'} $member.token) 403 'Member cannot add category'
    $category=Request POST 'categories' @{categoryName="Check $suffix";description='Test'} $admin.token
    Check $category 201 'Add category';$categoryId=[int]$category.Data.categoryId;$categoryIds.Add($categoryId)
    Check (Request GET 'categories' $null $member.token) 200 'List categories'
    Check (Request POST 'categories' @{categoryName="Check $suffix"} $admin.token) 409 'Duplicate category'
    Check (Request PUT "categories/$categoryId" @{categoryName="Updated $suffix";description='Edited'} $admin.token) 200 'Edit category'
    $uploadRoot=Join-Path $PSScriptRoot '..\SurveyApi\wwwroot\uploads'
    $filesBefore=@(Get-ChildItem -LiteralPath $uploadRoot -File).Count
    Check (UploadCategory $null "Image $suffix" $member.token) 403 'Member cannot upload category image'
    Check (UploadCategory $null "Image $suffix" $admin.token $true) 400 'Reject fake category image'
    $imageCategory=UploadCategory $null "Image $suffix" $admin.token
    Check $imageCategory 201 'Create category with image';$imageCategoryId=[int]$imageCategory.Data.categoryId;$categoryIds.Add($imageCategoryId)
    $catImage=CategoryPath $imageCategoryId $admin.token;$paths.Add($catImage)
    Check (ImageStatus $catImage) 200 'Category image served'
    Check (UploadCategory $null "Image $suffix" $admin.token) 409 'Duplicate category with upload rejected'
    if(@(Get-ChildItem -LiteralPath $uploadRoot -File).Count -ne $filesBefore+1){throw 'Failed category upload left files'}
    Check (UploadCategory $imageCategoryId "Updated $suffix" $admin.token) 409 'Failed image replacement preserves old category'
    if((CategoryPath $imageCategoryId $admin.token) -ne $catImage){throw 'Failed edit changed old category image'}
    Check (ImageStatus $catImage) 200 'Original category image kept on edit failure'
    Check (UploadCategory 2147483647 'Missing category' $admin.token) 404 'Upload to missing category'
    if(@(Get-ChildItem -LiteralPath $uploadRoot -File).Count -ne $filesBefore+1){throw 'Failed category edit left files'}
    Check (UploadCategory $imageCategoryId "Image $suffix" $admin.token) 200 'Replace category image'
    $catNewImage=CategoryPath $imageCategoryId $admin.token;$paths.Add($catNewImage)
    Check (ImageStatus $catImage) 404 'Replaced category old image removed'
    Check (ImageStatus $catNewImage) 200 'Replacement category image exists'
    Check (Request PUT "categories/$imageCategoryId" @{categoryName="Image $suffix";description='Without new image'} $admin.token) 200 'Edit category retains image'
    if((CategoryPath $imageCategoryId $admin.token) -ne $catNewImage){throw 'Category image unexpectedly changed'}
    Check (UploadCategory $imageCategoryId "Image $suffix" $admin.token $false $true) 200 'Remove category image only'
    if(CategoryPath $imageCategoryId $admin.token){throw 'Category image not cleared'}
    Check (ImageStatus $catNewImage) 404 'Removed category image file deleted'
    Check (UploadCategory $imageCategoryId "Image $suffix" $admin.token) 200 'Restore category image'
    $catFinalImage=CategoryPath $imageCategoryId $admin.token;$paths.Add($catFinalImage)
    Check (Request DELETE "categories/$imageCategoryId" $null $admin.token) 200 'Delete category with image'
    Check (ImageStatus $catFinalImage) 404 'Deleted category image removed'
    Check (UploadCategory $categoryId "Updated $suffix" $admin.token) 200 'Set image on category used later'
    $usedCategoryImage=CategoryPath $categoryId $admin.token;$paths.Add($usedCategoryImage)
    $questions=@(
        @{id=1;title='Feedback';type='text';required=$true;options=@()},
        @{id=2;title='Choice';type='single';required=$true;options=@('A','B')},
        @{id=3;title='Multiple';type='multiple';required=$true;options=@('X','Y')},
        @{id=4;title='Rating';type='rating';required=$true;options=@()}
    )
    Check (Upload $null 'No image' $categoryId $questions $admin.token $false) 400 'Survey requires image'
    Check (Upload $null 'Invalid image' $categoryId $questions $admin.token $true $true) 400 'Reject fake image'
    Check (Upload $null 'Forbidden' $categoryId $questions $member.token) 403 'Member cannot upload survey'
    for($i=1;$i -le 12;$i++){
        $created=Upload $null "Sample $suffix $i" $categoryId $questions $admin.token
        Check $created 201 "Add survey $i";$surveyIds.Add([int]$created.Data.surveyId)
        $detail=(Request GET "surveys/$($created.Data.surveyId)" $null $admin.token).Data;$paths.Add($detail.imagePath)
    }
    $surveyId=$surveyIds[0]
    $related=Request GET "surveys/$surveyId/related" $null $member.token
    Check $related 200 'Related surveys first page'
    if($related.Data.total -ne 11 -or @($related.Data.items).Count -ne 10 -or @($related.Data.items | Where-Object { $_.surveyId -eq $surveyId -or $_.categoryId -ne $categoryId }).Count){throw 'Wrong related surveys'}
    $related2=Request GET "surveys/$surveyId/related?page=2" $null $member.token
    Check $related2 200 'Related surveys second page'
    if(@($related2.Data.items).Count -ne 1 -or @($related.Data.items | Where-Object { $_.surveyId -eq $related2.Data.items[0].surveyId }).Count){throw 'Related pagination overlap'}
    Check (Request GET "surveys/$surveyId/related?page=0" $null $member.token) 400 'Related invalid page'
    Check (Request GET 'surveys/2147483647/related' $null $member.token) 404 'Related missing source'
    $firstPage=Request GET "surveys?categoryId=$categoryId&page=1&pageSize=10" $null $member.token
    Check $firstPage 200 'Survey page 1'
    if($firstPage.Data.total -ne 12 -or @($firstPage.Data.items).Count -ne 10){throw 'Wrong survey pagination'}
    $secondPage=Request GET "surveys?categoryId=$categoryId&page=2&pageSize=10" $null $member.token
    Check $secondPage 200 'Survey page 2';if(@($secondPage.Data.items).Count -ne 2){throw 'Wrong page 2'}
    $search=Request GET "surveys?search=$suffix&page=1&pageSize=10" $null $member.token
    Check $search 200 'Search pagination';if($search.Data.total -ne 12){throw 'Wrong search total'}
    Check (Request DELETE "categories/$categoryId" $null $admin.token) 409 'Cannot delete category containing survey'
    Check (ImageStatus $usedCategoryImage) 200 'Blocked category delete preserves image'
    $old=(Request GET "surveys/$surveyId" $null $member.token).Data.imagePath
    Check (ImageStatus $old) 200 'Image served'
    Check (Upload $surveyId 'Edited sample' $categoryId $questions $admin.token) 200 'Replace survey image'
    $replacement=(Request GET "surveys/$surveyId" $null $member.token).Data.imagePath;$paths.Add($replacement)
    if($old -eq $replacement){throw 'Image path not changed'}
    Check (ImageStatus $old) 404 'Old image removed'
    Check (ImageStatus $replacement) 200 'New image served'
    Check (Upload $surveyId 'Edited without image' $categoryId $questions $admin.token $false) 200 'Edit retains current image'
    if((Request GET "surveys/$surveyId" $null $member.token).Data.imagePath -ne $replacement){throw 'Image was lost'}
    Check (Request PUT "plan/$surveyId" @{targetCount=0} $member.token) 400 'Reject target zero'
    Check (Request PUT "plan/$surveyId" @{targetCount=5} $member.token) 200 'Add to plan'
    Check (Request PUT "plan/$($surveyIds[1])" @{targetCount=2} $member.token) 200 'Add another plan item'
    $plan=Request GET 'plan' $null $member.token;Check $plan 200 'Read plan';if(@($plan.Data).Count -ne 2){throw 'Wrong plan badge count'}
    Check (Request DELETE "plan/$($surveyIds[1])" $null $member.token) 200 'Remove plan item'
    Check (Request PUT "plan/$surveyId" @{targetCount=3} $member.token) 200 'Update target count'
    if(@((Request GET 'plan' $null $other.token).Data).Count -ne 0){throw 'Cross-member plan leak'}
    $requestId=[Guid]::NewGuid().ToString()
    $firstCheckout=Start-Post 'plan/checkout' @{title='Check campaign';requestId=$requestId} $member.token
    $secondCheckout=Start-Post 'plan/checkout' @{title='Check campaign';requestId=$requestId} $member.token
    $checkout=Finish-Post $firstCheckout
    Check $checkout 200 'Checkout';$campaignId=[int]$checkout.Data.campaignId;$campaignIds.Add($campaignId)
    $retry=Finish-Post $secondCheckout
    Check $retry 200 'Simultaneous checkout same request';if($retry.Data.campaignId -ne $campaignId){throw 'Checkout created duplicate'}
    if(@((Request GET 'plan' $null $member.token).Data).Count -ne 0){throw 'Plan not cleared'}
    Check (Request POST 'plan/checkout' @{title='Empty';requestId=[Guid]::NewGuid().ToString()} $member.token) 409 'Checkout empty plan blocked'
    Check (Request GET "campaigns/$campaignId" $null $member.token) 200 'Owner campaign details'
    Check (Request GET "campaigns/$campaignId" $null $other.token) 403 'Private campaign blocked'
    Check (Request GET 'campaigns' $null $admin.token) 200 'Admin campaign list'
    # Deterministic UTC timestamps around midnight in Vietnam; only temporary test data.
    Sql "UPDATE Campaigns SET CreatedAt='2026-01-01T17:00:00' WHERE CampaignId=$campaignId"
    $found=Request GET "campaigns?search=%23$campaignId" $null $member.token
    Check $found 200 'Owner search by code';if($found.Data.total -ne 1){throw 'Campaign code search failed'}
    $hidden=Request GET "campaigns?search=%23$campaignId" $null $other.token
    Check $hidden 200 'Search retains member privacy';if($hidden.Data.total -ne 0){throw 'Campaign search leaks private data'}
    $byName=Request GET 'campaigns?search=Check%20campaign&fromDate=2026-01-02&toDate=2026-01-02' $null $member.token
    Check $byName 200 'Search with inclusive local day';if($byName.Data.total -ne 1){throw 'Local midnight start excluded'}
    $previous=Request GET "campaigns?search=%23$campaignId&toDate=2026-01-01" $null $admin.token
    Check $previous 200 'Date excludes next local day';if($previous.Data.total -ne 0){throw 'Wrong local date boundary'}
    Sql "UPDATE Campaigns SET CreatedAt='2026-01-02T16:59:59.9999999' WHERE CampaignId=$campaignId"
    $endDay=Request GET "campaigns?search=%23$campaignId&fromDate=2026-01-02&toDate=2026-01-02" $null $admin.token
    Check $endDay 200 'Admin search includes local day end';if($endDay.Data.total -ne 1){throw 'Local day end excluded'}
    Check (Request GET 'campaigns?fromDate=2026-01-03&toDate=2026-01-02' $null $admin.token) 400 'Reject reversed date range'
    Check (Request GET 'campaigns?fromDate=0001-01-01' $null $admin.token) 400 'Reject date underflow'
    Check (Request GET 'campaigns?toDate=9999-12-31' $null $admin.token) 400 'Reject date overflow'
    for($i=1;$i -le 11;$i++){
        Check (Request PUT "plan/$surveyId" @{targetCount=1} $member.token) 200 'Prepare search pagination'
        $extra=Request POST 'plan/checkout' @{title="Filter $suffix $i";requestId=[Guid]::NewGuid().ToString()} $member.token
        Check $extra 200 'Create search pagination campaign';$campaignIds.Add([int]$extra.Data.campaignId)
    }
    $filtered=Request GET "campaigns?search=Filter%20$suffix&page=1" $null $member.token
    Check $filtered 200 'Filtered campaigns first page'
    if($filtered.Data.total -ne 11 -or @($filtered.Data.items).Count -ne 10){throw 'Wrong filtered total'}
    $filtered2=Request GET "campaigns?search=Filter%20$suffix&page=2" $null $admin.token
    Check $filtered2 200 'Admin filtered campaigns second page'
    if($filtered2.Data.total -ne 11 -or @($filtered2.Data.items).Count -ne 1){throw 'Wrong filtered second page'}
    $closedSearch=Request GET "campaigns?open=true&search=Filter%20$suffix" $null $other.token
    Check $closedSearch 200 'Search open list excludes pending campaigns'
    if($closedSearch.Data.total -ne 0){throw 'Pending campaign leaked into open list'}
    Check (Upload $surveyId 'Locked edit' $categoryId $questions $admin.token) 409 'Used survey cannot edit'
    Check (Request DELETE "surveys/$surveyId" $null $admin.token) 409 'Used survey cannot delete'
    Check (Request PUT "campaigns/$campaignId/status" @{status='Active'} $member.token) 403 'Member cannot set status'
    Check (Request PUT "campaigns/$campaignId/status" @{status='Closed'} $admin.token) 409 'Invalid status transition'
    Check (Request PUT "campaigns/$campaignId/status" @{status='Active'} $admin.token) 200 'Open campaign'
    Check (Request GET 'campaigns?open=true' $null $other.token) 200 'Open campaigns list'
    $details=(Request GET "campaigns/$campaignId" $null $other.token).Data;$itemId=[int]$details.items[0].itemId
    if($details.items[0].targetCount -ne 3){throw 'Checkout target lost'}
    Check (Request POST "campaigns/$campaignId/items/$itemId/responses" @{submissionId=[Guid]::NewGuid().ToString();answers=@{}} $other.token) 400 'Required answers enforced'
    Check (Request POST "campaigns/$campaignId/items/$itemId/responses" @{submissionId=[Guid]::NewGuid().ToString();answers=@{'1'='Hi';'2'='INVALID';'3'=@('X');'4'=5}} $other.token) 400 'Invalid option blocked'
    Check (Request POST "campaigns/$campaignId/items/$itemId/responses" @{submissionId=[Guid]::NewGuid().ToString();answers=@{'1'='Hi';'2'='A';'3'=@('X','X');'4'=5}} $other.token) 400 'Duplicate multiple-choice selection blocked'
    Check (Request POST "campaigns/$campaignId/items/$itemId/responses" @{submissionId=[Guid]::NewGuid().ToString();answers=@{'1'='Hi';'2'='A';'3'=@('X');'4'=6}} $other.token) 400 'Out-of-range rating blocked'
    $submission=[Guid]::NewGuid().ToString();$body=@{submissionId=$submission;answers=@{'1'='Good';'2'='A';'3'=@('X','Y');'4'=5}}
    $firstResponse=Start-Post "campaigns/$campaignId/items/$itemId/responses" $body $other.token
    $secondResponse=Start-Post "campaigns/$campaignId/items/$itemId/responses" $body $other.token
    Check (Finish-Post $firstResponse) 200 'Submit response'
    Check (Finish-Post $secondResponse) 200 'Simultaneous same response idempotently'
    $body.submissionId=[Guid]::NewGuid().ToString()
    Check (Request POST "campaigns/$campaignId/items/$itemId/responses" $body $other.token) 409 'Second response rejected'
    Check (Request GET "campaigns/$campaignId/items/$itemId/results" $null $other.token) 403 'Non-owner cannot view results'
    $results=Request GET "campaigns/$campaignId/items/$itemId/results" $null $member.token;Check $results 200 'Owner results'
    if($results.Data.total -ne 1 -or $results.Data.questions[3].average -ne 5 -or $results.Data.questions[1].options[0].count -ne 1){throw 'Statistics incorrect'}
    Check (Request PUT "campaigns/$campaignId/status" @{status='Closed'} $admin.token) 200 'Close campaign'
    $body.submissionId=[Guid]::NewGuid().ToString()
    Check (Request POST "campaigns/$campaignId/items/$itemId/responses" $body $member.token) 409 'Closed campaign rejects response'
    $unused=$surveyIds[11];$unusedPath=(Request GET "surveys/$unused" $null $admin.token).Data.imagePath
    Check (Request DELETE "surveys/$unused" $null $admin.token) 200 'Delete unused survey'
    Check (ImageStatus $unusedPath) 404 'Deleted survey image removed'
    $empty=Request POST 'categories' @{categoryName="Empty $suffix"} $admin.token;$emptyId=[int]$empty.Data.categoryId;$categoryIds.Add($emptyId)
    Check (Request DELETE "categories/$emptyId" $null $admin.token) 200 'Delete empty category'
    Check (Request DELETE "members/$($member.member.memberId)" $null $admin.token) 409 'Cannot delete member with campaign data'
    Check (Request DELETE "members/$($admin.member.memberId)" $null $admin.token) 400 'Cannot delete own admin account'
    Check (Request POST 'auth/change-password' @{currentPassword='Wrong@123456';newPassword='Changed@123456'} $member.token) 400 'Wrong current password blocked'
    Check (Request POST 'auth/change-password' @{currentPassword=$password;newPassword=$password} $member.token) 400 'Same password blocked'
    Check (Request POST 'auth/change-password' @{currentPassword=$password;newPassword='Changed@123456'} $member.token) 200 'Change password'
    Check (Request GET 'auth/me' $null $member.token) 401 'Old token rejected after password change'
    Check (Request POST 'auth/login' @{email=$memberEmail;password=$password} '') 401 'Old password rejected'
    $member=(Request POST 'auth/login' @{email=$memberEmail;password='Changed@123456'} '').Data
    Check (Request PUT "members/$($member.member.memberId)" @{fullName='Temporary';roleName='SuperAdmin';isActive=$true} $admin.token) 400 'Unknown role rejected'
    Check (Request PUT "members/$($member.member.memberId)" @{fullName='Temporary';roleName='Member';isActive=$false} $admin.token) 200 'Lock account'
    Check (Request GET 'auth/me' $null $member.token) 401 'Locked account token rejected'
    Check (Request POST 'auth/login' @{email=$memberEmail;password='Changed@123456'} '') 401 'Locked account login rejected'
    Check (Request PUT "members/$($member.member.memberId)" @{fullName='Temporary';roleName='Member';isActive=$true} $admin.token) 200 'Unlock account'
    $member=(Request POST 'auth/login' @{email=$memberEmail;password='Changed@123456'} '').Data
    Check (Request POST 'auth/logout' @{} $member.token) 200 'Server logout'
    Check (Request GET 'auth/me' $null $member.token) 401 'Token rejected after logout'
    Write-Output "ALL $checks CHECKS PASSED"
}finally{
    if($campaignIds.Count){$ids=$campaignIds -join ',';Sql "DELETE FROM Responses WHERE ItemId IN(SELECT ItemId FROM CampaignItems WHERE CampaignId IN($ids)); DELETE FROM CampaignItems WHERE CampaignId IN($ids); DELETE FROM Campaigns WHERE CampaignId IN($ids);"}
    if($surveyIds.Count){$ids=$surveyIds -join ',';Sql "DELETE FROM PlanItems WHERE SurveyId IN($ids); DELETE FROM Surveys WHERE SurveyId IN($ids);"}
    if($categoryIds.Count){$ids=$categoryIds -join ',';Sql "DELETE FROM Categories WHERE CategoryId IN($ids);"}
    Sql "DELETE FROM Members WHERE Email IN('$adminEmail','$memberEmail','$otherEmail')"
    $uploadRoot=Join-Path $PSScriptRoot '..\SurveyApi\wwwroot\uploads'
    foreach($path in $paths){$name=[IO.Path]::GetFileName($path);$target=Join-Path $uploadRoot $name;if(Test-Path -LiteralPath $target){Remove-Item -LiteralPath $target}}
    $http.Dispose()
}
