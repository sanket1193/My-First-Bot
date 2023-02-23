*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.PDF
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.Archive


*** Tasks ***
Launch the robot order website
    Open the robot order website

Order robots from RobotSpareBin Industries Inc
    ${orders}=    Read Excel File
    FOR    ${order}    IN    @{orders}
        Handle modal
        Fill Single Order    ${order}
        Wait Until Keyword Succeeds    10x    2s    Take screenshot of Preview    ${order}
        Wait Until Keyword Succeeds    10x    2s    Create Receipt PDF    ${order}
        Embed Scrrenshot to PDF    ${order}
    END

Close Browser
    Close The Application


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=${True}

Handle modal
    Click Element If Visible    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Read Excel File
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${order_details}=    Read table from CSV    orders.csv    header=${True}
    RETURN    ${order_details}

Fill Single Order
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Click Element    id-body-${order}[Body]
    Input Text    xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${order}[Legs]
    Input Text    address    ${order}[Address]

Take screenshot of Preview
    [Arguments]    ${order}
    Click Button    preview
    Set Local Variable    ${img_robot}    //*[@id="robot-preview-image"]
    Wait Until Element Is Enabled    ${img_robot}
    Capture Element Screenshot
    ...    ${img_robot}
    ...    ${OUTPUT_DIR}${/}${order}[Order number].png

Create Receipt PDF
    [Arguments]    ${order}
    Click Button    order
    Wait Until Element Is Visible    //*[@id="receipt"]
    ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML
    Html To Pdf    ${order_receipt_html}    output_path=${OUTPUT_DIR}${/}PDF${/}${order}[Order number].pdf
    Click Button    order-another

Embed Scrrenshot to PDF
    [Arguments]    ${order}
    @{image_list}=    Create List    ${OUTPUT_DIR}${/}${order}[Order number].png:x=0,y=0
    Log    ${image_list}
    Open Pdf    ${OUTPUT_DIR}${/}PDF${/}${order}[Order number].pdf
    Add Files To Pdf    ${image_list}    ${OUTPUT_DIR}${/}PDF${/}${order}[Order number].pdf    append=${True}
    Close Pdf    ${OUTPUT_DIR}${/}PDF${/}${order}[Order number].pdf

Close The Application
    Close Browser
