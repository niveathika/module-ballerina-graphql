// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/mime;
import ballerina/test;

@test:Config {
    groups: ["file_upload"]
}
isolated function testSingleFileUpload() returns error? {
    string document = string`mutation($file: FileUpload!){ singleFileUpload(file: $file) { fileName, mimeType, content } }`;
    json variables = {"file": null} ;

    json operation = {
        "query":document,
        "variables": variables
    }; 

    json pathMap =  { "0": ["file"]};

    mime:Entity operations = new;
    mime:ContentDisposition contentDisposition1 = new;
    contentDisposition1.name = "operations";
    contentDisposition1.disposition = "form-data";
    operations.setContentDisposition(contentDisposition1);
    operations.setJson(operation);

    mime:Entity path = new;
    mime:ContentDisposition contentDisposition2 = new;
    contentDisposition2.name = "map";
    contentDisposition2.disposition = "form-data";
    path.setContentDisposition(contentDisposition2);
    path.setJson(pathMap);

    mime:Entity jsonFilePart = new;
    jsonFilePart.setHeader("Content-Encoding", "gzip");
    mime:ContentDisposition contentDisposition3 = new;
    contentDisposition3.name = "0";
    contentDisposition3.disposition = "form-data";
    contentDisposition3.fileName = "sample1.json";
    jsonFilePart.setContentDisposition(contentDisposition3);
    jsonFilePart.setFileAsEntityBody("./tests/resources/files/sample1.json", contentType = mime:APPLICATION_JSON);

    mime:Entity[] bodyParts = [operations, path, jsonFilePart];
    http:Request request = new;
    request.setBodyParts(bodyParts, contentType = mime:MULTIPART_FORM_DATA);

    http:Client httpClient = check new("http://localhost:9091");
    json actualPayload = check httpClient->post("/fileUpload", request);
    json expectedPayload = check getJsonContentFromFile("single_file_upload.json");
    assertJsonValuesWithOrder(actualPayload, expectedPayload);
}


@test:Config {
    groups: ["file_upload"]
}
isolated function testMultipleFileUpload() returns error? {
    string document = string`mutation($files: [FileUpload!]!){ multipleFileUpload(files: $files) { fileName, content } }`;
    json variables = {"files": [null, null, null]} ;

    json operation = {
        "query":document,
        "variables": variables
    }; 

    json pathMap =  {
        "0": ["files.0"],
        "1": ["files.1"],
        "2": ["files.2"]
    };

    mime:Entity operations = new;
    mime:ContentDisposition contentDisposition1 = new;
    contentDisposition1.name = "operations";
    contentDisposition1.disposition = "form-data";
    operations.setContentDisposition(contentDisposition1);
    operations.setJson(operation);

    mime:Entity path = new;
    mime:ContentDisposition contentDisposition2 = new;
    contentDisposition2.name = "map";
    contentDisposition2.disposition = "form-data";
    path.setContentDisposition(contentDisposition2);
    path.setJson(pathMap);

    mime:Entity jsonFilePart = new;
    mime:ContentDisposition contentDisposition3 = new;
    contentDisposition3.name = "0";
    contentDisposition3.disposition = "form-data";
    contentDisposition3.fileName = "sample1.json";
    jsonFilePart.setContentDisposition(contentDisposition3);
    jsonFilePart.setFileAsEntityBody("./tests/resources/files/sample1.json", contentType = mime:APPLICATION_JSON);

    mime:Entity txtFilePart = new;
    mime:ContentDisposition contentDisposition4 = new;
    contentDisposition4.name = "1";
    contentDisposition4.disposition = "form-data";
    contentDisposition4.fileName = "sample2.txt";
    txtFilePart.setContentDisposition(contentDisposition4);
    txtFilePart.setFileAsEntityBody("./tests/resources/files/sample2.txt", contentType = mime:TEXT_PLAIN);

    mime:Entity xmlFilePart = new;
    mime:ContentDisposition contentDisposition5 = new;
    contentDisposition5.name = "2";
    contentDisposition5.disposition = "form-data";
    contentDisposition5.fileName = "sample3.xml";
    xmlFilePart.setContentDisposition(contentDisposition5);
    xmlFilePart.setFileAsEntityBody("./tests/resources/files/sample3.xml", contentType = mime:APPLICATION_XML);

    mime:Entity[] bodyParts = [operations, path, jsonFilePart, txtFilePart, xmlFilePart];
    http:Request request = new;
    request.setBodyParts(bodyParts, contentType = mime:MULTIPART_FORM_DATA);

    http:Client httpClient = check new("http://localhost:9091");
    json actualPayload = check httpClient->post("/fileUpload", request);
    json expectedPayload = check getJsonContentFromFile("multiple_file_upload.json");
    assertJsonValuesWithOrder(actualPayload, expectedPayload);
}

@test:Config {
    groups: ["file_upload"]
}
isolated function testUndefinedVariableWithMultipartRequest() returns error? {
    string document = string`mutation($files: [FileUpload!]!){ multipleFileUpload(files: $files) { fileName }}`;
    json variables = {"files": [null]} ;

    json operation = {
        "query":document,
        "variables": variables
    };

    json pathMap =  {
        "0": ["files.1"]
    };

    mime:Entity operations = new;
    mime:ContentDisposition contentDisposition1 = new;
    contentDisposition1.name = "operations";
    contentDisposition1.disposition = "form-data";
    operations.setContentDisposition(contentDisposition1);
    operations.setJson(operation);

    mime:Entity path = new;
    mime:ContentDisposition contentDisposition2 = new;
    contentDisposition2.name = "map";
    contentDisposition2.disposition = "form-data";
    path.setContentDisposition(contentDisposition2);
    path.setJson(pathMap);

    mime:Entity jsonFilePart = new;
    mime:ContentDisposition contentDisposition3 = new;
    contentDisposition3.name = "0";
    contentDisposition3.disposition = "form-data";
    contentDisposition3.fileName = "sample1.json";
    jsonFilePart.setContentDisposition(contentDisposition3);
    jsonFilePart.setFileAsEntityBody("./tests/resources/files/sample1.json", contentType = mime:APPLICATION_JSON);

    mime:Entity[] bodyParts = [operations, path];
    http:Request request = new;
    request.setBodyParts(bodyParts, contentType = mime:MULTIPART_FORM_DATA);

    http:Client httpClient = check new("http://localhost:9091");
    http:Response response = check httpClient->post("/fileUpload", request);
    int statusCode = response.statusCode;
    test:assertEquals(statusCode, 400);
    string actualPaylaod = check response.getTextPayload();
    string expectedMessage = "Undefined variable found in multipart request `map`";
    test:assertEquals(actualPaylaod, expectedMessage);
}

@test:Config {
    groups: ["file_upload"]
}
isolated function testMissingContentInMultipartRequest() returns error? {
    string document = string`mutation($files: [FileUpload!]!){ multipleFileUpload(files: $files) }`;
    json variables = {"files": [null, null]} ;

    json operation = {
        "query":document,
        "variables": variables
    };

    json pathMap =  {
        "0": ["files.0"]
    };

    mime:Entity operations = new;
    mime:ContentDisposition contentDisposition1 = new;
    contentDisposition1.name = "operations";
    contentDisposition1.disposition = "form-data";
    operations.setContentDisposition(contentDisposition1);
    operations.setJson(operation);

    mime:Entity path = new;
    mime:ContentDisposition contentDisposition2 = new;
    contentDisposition2.name = "map";
    contentDisposition2.disposition = "form-data";
    path.setContentDisposition(contentDisposition2);
    path.setJson(pathMap);

    mime:Entity jsonFilePart = new;
    mime:ContentDisposition contentDisposition3 = new;
    contentDisposition3.name = "0";
    contentDisposition3.disposition = "form-data";
    contentDisposition3.fileName = "sample1.json";
    jsonFilePart.setContentDisposition(contentDisposition3);
    jsonFilePart.setFileAsEntityBody("./tests/resources/files/sample1.json", contentType = mime:APPLICATION_JSON);

    mime:Entity[] bodyParts = [operations, path];
    http:Request request = new;
    request.setBodyParts(bodyParts, contentType = mime:MULTIPART_FORM_DATA);

    http:Client httpClient = check new("http://localhost:9091");
    http:Response response = check httpClient->post("/fileUpload", request);
    int statusCode = response.statusCode;
    test:assertEquals(statusCode, 400);
    string actualPaylaod = check response.getTextPayload();
    string expectedMessage = "File content is missing in multipart request";
    test:assertEquals(actualPaylaod, expectedMessage);
}

@test:Config {
    groups: ["file_upload"]
}
isolated function testInvalidMapFieldInMultipartRequest() returns error? {
    string document = string`mutation($files: [FileUpload!]!){ multipleFileUpload(files: $files) }`;
    json variables = {"files": [null]} ;

    json operation = {
        "query":document,
        "variables": variables
    };

    json pathMap =  {
        "0": "files.0"
    };

    mime:Entity operations = new;
    mime:ContentDisposition contentDisposition1 = new;
    contentDisposition1.name = "operations";
    contentDisposition1.disposition = "form-data";
    operations.setContentDisposition(contentDisposition1);
    operations.setJson(operation);

    mime:Entity path = new;
    mime:ContentDisposition contentDisposition2 = new;
    contentDisposition2.name = "map";
    contentDisposition2.disposition = "form-data";
    path.setContentDisposition(contentDisposition2);
    path.setJson(pathMap);

    mime:Entity[] bodyParts = [operations, path];
    http:Request request = new;
    request.setBodyParts(bodyParts, contentType = mime:MULTIPART_FORM_DATA);

    http:Client httpClient = check new("http://localhost:9091");
    http:Response response = check httpClient->post("/fileUpload", request);
    int statusCode = response.statusCode;
    test:assertEquals(statusCode, 400);
    string actualPaylaod = check response.getTextPayload();
    string expectedMessage = "Invalid type for multipart request field ‘map’";
    test:assertEquals(actualPaylaod, expectedMessage);
}

@test:Config {
    groups: ["file_upload"]
}
isolated function testInvalidMapTypeInMultipartRequest() returns error? {
    string document = string`mutation($files: [FileUpload!]!){ multipleFileUpload(files: $files) }`;
    json variables = {"files": [null]} ;

    json operation = {
        "query":document,
        "variables": variables
    };

    json pathMap =  {
        "0": [2]
    };

    mime:Entity operations = new;
    mime:ContentDisposition contentDisposition1 = new;
    contentDisposition1.name = "operations";
    contentDisposition1.disposition = "form-data";
    operations.setContentDisposition(contentDisposition1);
    operations.setJson(operation);

    mime:Entity path = new;
    mime:ContentDisposition contentDisposition2 = new;
    contentDisposition2.name = "map";
    contentDisposition2.disposition = "form-data";
    path.setContentDisposition(contentDisposition2);
    path.setJson(pathMap);

    mime:Entity jsonFilePart = new;
    mime:ContentDisposition contentDisposition3 = new;
    contentDisposition3.name = "0";
    contentDisposition3.disposition = "form-data";
    contentDisposition3.fileName = "sample1.json";
    jsonFilePart.setContentDisposition(contentDisposition3);
    jsonFilePart.setFileAsEntityBody("./tests/resources/files/sample1.json", contentType = mime:APPLICATION_JSON);

    mime:Entity[] bodyParts = [operations, path];
    http:Request request = new;
    request.setBodyParts(bodyParts, contentType = mime:MULTIPART_FORM_DATA);

    http:Client httpClient = check new("http://localhost:9091");
    http:Response response = check httpClient->post("/fileUpload", request);
    int statusCode = response.statusCode;
    test:assertEquals(statusCode, 400);
    string actualPaylaod = check response.getTextPayload();
    string expectedMessage = "Invalid type for multipart request field ‘map’ value";
    test:assertEquals(actualPaylaod, expectedMessage);
}
