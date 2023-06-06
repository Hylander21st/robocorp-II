*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.
...

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.HTTP
Library             RPA.PDF
Library             Collections
Library             OperatingSystem
Library             RPA.FileSystem
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the website
    Download the Excel file
    Click Modal
    Read the CSV file into tables and log all rows
    Create ZIP package from receipts directory


*** Keywords ***
Open the website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the Excel file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    
Read the CSV file into tables and log all rows
    ${tables}=    Read Table From Csv    ${CURDIR}${/}orders.csv    header=True
    FOR    ${row}    IN    @{tables}
        Fill and submit the form for one row    ${row}
    END
Click Modal
    Click Button    OK

Order
    Click Button    order
    Wait Until Element Is Visible    id:receipt

Orderanother
    Click Button    order-another

Fill and submit the form for one row
    [Arguments]    ${row}

    Wait Until Element Is Visible    id:head
    Select From List By Value    id=head    ${row['Head']}
    Click Element    css=#id-body-${row['Body']}
    Input Text    css=.form-control    ${row['Legs']}
    Input Text    address    ${row['Address']}
    Sleep    2s
    Click Button    Preview

    Wait Until Keyword Succeeds    10x    1s    Order

    Sleep    5s

    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}receipts${/}receipt${row['Order number']}.pdf
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}receipts${/}robot${row['Order number']}.png
    ${receiptpdf}=    Open Pdf    ${OUTPUT_DIR}${/}receipts${/}receipt${row['Order number']}.pdf
    ${robotpicture}=    Create List
    ...    ${OUTPUT_DIR}${/}receipts${/}robot${row['Order number']}.png
    ...    ${OUTPUT_DIR}${/}receipts${/}receipt${row['Order number']}.pdf
    Add Files To Pdf    ${robotpicture}    ${OUTPUT_DIR}${/}receipts${/}receipt${row['Order number']}.pdf
    Close Pdf    ${receiptpdf}

    Wait Until Keyword Succeeds    10x    2s    Orderanother

    Click Modal

Create ZIP package from receipts directory
    Archive Folder With Zip    ${OUTPUT_DIR}${/}receipts    ${OUTPUT_DIR}${/}receipts.zip
