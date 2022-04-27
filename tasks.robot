*** Settings ***
Documentation     Logging data to roboSparebin 
Library    RPA.Browser.Selenium    auto_close=${FALSE}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive
Library    RPA.Robocorp.Vault


*** Tasks ***
Logging data to roboSparebin
    Open Navegador
    Login
    Download csv file  
    Read css file
    Create ZIP 
    [Teardown]    Log out and close the browser


*** Keywords ***
Open Navegador
    Open Available Browser    https://robotsparebinindustries.com/

Login
    ${secret}=    Get Secret    Login
    Input Text    username    ${secret}[username]  
    Input Password    password    ${secret}[password]
    Submit Form
    Wait Until Page Contains Element    id:sales-form
    Click Element    //a[@class="nav-link"]
    Wait Until Page Contains Element    //div[@class="alert-buttons"]    timeout=10
    Click Button    OK

Download csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True


Place values
    [Arguments]    ${tables_csv}
    Select From List By Value    head    ${tables_csv}[Head]
    Click Element    //label[@for="id-body-${tables_csv}[Body]"]/input[@value=${tables_csv}[Body]]
    Input Text    //input[@class="form-control"]    ${tables_csv}[Legs]
    Input Text    address    ${tables_csv}[Address] 
    Click Button    //button[@class="btn btn-secondary"]    
           


Read css file
    ${table_csv}=    Read table from CSV    orders.csv
    Log   Found columns: ${table_csv.columns[0]}
    FOR    ${tables_csv}    IN    @{table_csv}
        Place values    ${tables_csv}
        Wait Until Keyword Succeeds    15x    0.5s    Create PDF    ${tables_csv}
        IMG PDF    ${tables_csv}
        Wait Until Keyword Succeeds    3 times    0.5 sec     Return page
        Click spam
    END


Return page
    Click Button    //button[@id="order-another"]
    

Create PDF        
    [Arguments]    ${tables_csv}
    Click Button    //button[@class="btn btn-primary"]
    Wait Until Page Contains Element    //div[@class="container"]
    ${sales_results_html}=    Get Element Attribute    //div[@id="receipt"]    outerHTML
    Html To Pdf    ${sales_results_html}    ${OUTPUT_DIR}${/}PDfS${/}pdf_robots_${tables_csv}[Order number].pdf
    # Close Pdf    ${OUTPUT_DIR}${/}pdf_robots_${tables_csv}[Order number]    

IMG PDF
    [Arguments]    ${tables_csv}
    Wait Until Page Contains Element    //div[@id="robot-preview-image"]
    ${Screenshot_img}=    Screenshot    //div[@id="robot-preview-image"]    ${OUTPUT_DIR}${/}image_robot_${tables_csv}[Order number].png
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}image_robot_${tables_csv}[Order number].png  
    Open Pdf    ${OUTPUT_DIR}${/}PDfS${/}pdf_robots_${tables_csv}[Order number].pdf 
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}PDfS${/}pdf_robots_${tables_csv}[Order number].pdf    append=${TRUE}
    Close Pdf
   

Create ZIP
    Archive Folder With Zip    ${OUTPUT_DIR}${/}PDfS    ${OUTPUT_DIR}${/}PDFS_robots.zip

Click spam
    Wait Until Page Contains Element    //div[@class="alert-buttons"]    timeout=10
    Click Button    OK

Log out and close the browser
    Click Button    Log out
    Close Browser 