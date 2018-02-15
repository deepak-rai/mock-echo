mock-echo
===

Simple HTTP mock server which can be set for given url, parameter to return intended response, response code. Also has a counter to track the hits to the request endpoint. In addition to this has a file hosting endpoint too.

## Installation and running the mock-echo ##


#### Pre-requisite installation
- Ubuntu Installation :
```
sudo apt-get update
sudo apt-get install -y nodejs npm
npm install csv-parse raw-body content-type csv-parse csv formidable st path sql.js uuid randomstring date-and-time time
```
- Mac Installation:
```
# Install homebrew - https://raw.githubusercontent.com/Homebrew/install/master/install
brew install node
npm install csv-parse raw-body content-type csv-parse csv formidable st path sql.js uuid randomstring date-and-time time
```

#### Start mock-echo

Download the `index.js` and run the following
```
mkdir -p file_upload
node index.js 8014 # Any free port
```


## Run the docker ##

Required to pass the optional port(`SERVER_PORT`) in the docker run command, on which the HTTP server is intended to run.
- For initial bootstrapping of URL's, can mount a csv file which consists of `"url","response",responseCode` to `/var/lib/mock-echo/sample.csv`, which will be loaded onto mock-echo.
- Server logs can be found in `/var/logs/mock-echo/server.log` inside the docker.

Docker run command : `docker run -t -d --net=host -e SERVER_PORT=<http-server-port> <optional-sample-csv-file-mount> <docker-image>`

Sample Docker run command : `docker run --name mock-echo -t -d --net=host -e SERVER_PORT=8014 -v /home/deepak.rai/mock/sample.csv:/var/lib/mock-echo/sample.csv drai82/mock-echo`

## Endpoints ##

- `/set` : Set the desired request URL, response, response code in URL parameters to mock-echo. URL parameters:
  - `url` : Url request path
  - `response` : Response to be returned
  - `responseCode` : Response code to be returned. By default, set to 200.
  - additional url parameters : Url parameters in addition to the URL. For example, `a=b&c=d`
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/set?url=hello&response=\[\{"target":"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count"\}\]&responseCode=404&a=b&c=d'
    {
        "url": "hello",
        "parameters": "a=b&c=d",
        "response": "[{\"target\":\"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count\"}]",
        "responseCode": "404",
        "counter": 0
    }
    ```
- `/setViaPost` : Same as `/set`, but send HTTP response via POST request. URL parameters:
  - `url` : Url request path
  - `responseCode` : Response code to be returned. By default, set to 200.
  - additional url parameters : Url parameters in addition to the URL. For example, `a=b&c=d`
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ $ curl -d '{"name": "mkyong","age": 30,"address": {"streetAddress": "88 8nd Street","city": "New York"},"phoneNumber": [{"type": "home","nber": "111 111-1111"},{"type": "fax","number": "222 222-2222"}]}' "http://localhost:8014/setViaPost?url=hello10&myParam1=a&myParam2=b"
    OK
    ```
- `/setBulkViaCSV` : Upload a csv consisting of `"url","parameters","response","responseCode"` entries and use it for bulk setting up of URL's.
  - Sample:
  ```sh
  deepak.rai@localhost tmp $ cat sample.csv
  "hello1","","response1",200
  "hello3"
  "hello2","","response2","404"
  "hello4","a=b","[""]"
  "hello5","c=b","buss"
  "hello6","x=5&y=9","[{""target"":""prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.1count""}]"
  "hello7","mykey1=5&my_key2=93","imksddsdazwsexdcrftvgbyhunjimkjnhgtfdrxeswsedrcftvgybh"

  deepak.rai@localhost tmp $ curl -F 'data=@sample.csv' "http://localhost:8014/setBulkViaCSV"
  OK
  ```
- `/get` : Get the details of request URL. Returns - request URL path, response, response code and hit count. URL parameters:
  - `url` : Url request path
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/get?url=hello&a=b&c=d'
    {
        "url": "hello",
        "parameters": "a=b&c=d",
        "response": "[{\"target\":\"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count\"}]",
        "responseCode": 404,
        "counter": 3
    }
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/get?url=nonExistentRequestPath'
    {
        "error": "URL not set"
    }
    ```
- `/reset` : Reset the counter of request URL. URL parameters:
  - `url` : Url request path
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/reset?url=hello'
    {
        "url": "hello",
        parameters: "",
        "response": "[{\"target\":\"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count\"}]",
        "responseCode": 404,
        "counter": 0
    }
    ```
- Hit the already set request path URL, should return the intended response. mock-echo internally will the bump the counter for this request path. Sample, set to a specific response and the response code to 404:
```sh
deepak.rai@localhost tmp $ curl 'http://localhost:8014/hello' -i
HTTP/1.1 404 Not Found
Date: Wed, 19 Jul 2017 02:31:58 GMT
Connection: keep-alive
Transfer-Encoding: chunked

[{"target":"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count"}]
```
- `/delete` : Delete the set request URL, response, response code for given URL parameters in mock-echo. URL parameters:
  - `url` : Url request path
  - `responseCode` : Response code to be returned. By default, set to 200.
  - additional url parameters : Url parameters in addition to the URL. For example, `a=b&c=d`
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl "http://localhost:8014/delete?url=hello&a=b&c=d"
    Deleted successfully!
    ```
- `/fileUpload` : File hosting. URL parameters:
  - `url` : Url request path
   - Sample:
   ```sh
   deepak.rai@localhost tmp $ curl -X POST -F 'file=@myFile.png' "http://localhost:8014/fileUpload"
   File uploaded!
   deepak.rai@localhost tmp $ curl -X POST -F 'file=@temp.txt' http://localhost:8014/fileUpload?url=hello/world/
   File uploaded!
   deepak.rai@localhost tmp $ curl -X POST -F 'file=@myImage.png' "http://localhost:8014/fileUpload?url=hello/world/&myParam1=a1&myParam2=b2"
   File uploaded !
   ```
- `/fileDownload` : Download a hosted file.
  - Sample:
  ```sh
  deepak.rai@localhost tmp $  wget "http://localhost:8014/fileDownload/hello/world/myFile.png"
  --2017-09-18 14:31:29--  http://localhost:8014/fileDownload/hello/world/myFile.png
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 204804 (200K) [image/png]
  Saving to: 'myFile.png.1'

  myFile.png.1                  100%[================================================>] 200.00K  --.-KB/s   in 0.001s

  2017-09-18 14:31:29 (197 MB/s) - 'myFile.png.1' saved [204804/204804]

  deepak.rai@localhost tmp $  wget "http://localhost:8014/hello/world/myFile.png"
  --2017-09-18 14:31:39--  http://localhost:8014/hello/world/myFile.png
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: unspecified [application/octet-stream]
  Saving to: 'myFile.png.2'

  myFile.png.2                      [ <=>                                             ] 200.00K  --.-KB/s   in 0s

  2017-09-18 14:31:39 (519 MB/s) - 'myFile.png.2' saved [204804]

  deepak.rai@localhost tmp wget "http://localhost:8014/hello/world/myImage.png?myParam1=a1&myParam2=b2"
  --2017-09-18 14:36:30--  http://localhost:8014/hello/world/myImage.png?myParam1=a1&myParam2=b2
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: unspecified [application/octet-stream]
  Saving to: 'myImage.png?myParam1=a1&myParam2=b2'

  myImage.png?myParam1=a1&myPar     [ <=>                                             ] 200.00K  --.-KB/s   in 0s

  2017-09-18 14:36:30 (462 MB/s) - 'myImage.png?myParam1=a1&myParam2=b2' saved [204804]

  deepak.rai@localhost tmp $ wget "http://localhost:8014/fileDownload/hello/world/temp.txt"
  --2017-09-05 15:31:29--  http://localhost:8014/fileDownload/hello/world/temp.txt
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 20 [text/plain]
  Saving to: 'temp.txt.1'

  temp.txt.1                                                 100%[==========================================================================================================================================>]      20  --.-KB/s   in 0s

  2017-09-05 15:31:29 (2.12 MB/s) - 'temp.txt.1' saved [20/20]
  ```
- `/fileDelete` : Download a hosted file.  URL parameters:
  - `file` : Filename to be deleted
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl "http://localhost:8014/fileDelete?file=myFile.png"
    File deleted successfully - myFile.png !
    deepak.rai@localhost tmp $ curl "http://localhost:/fileDelete?file=hello/world/temp.txt"
    File deleted successfully - hello/world/temp.txt !
    ```

## Macros ##

mock-echo supports some pre-defined placehoder macros in response which gets replaced at runtime:

| Macro | Description | Sample |
| --- | --- | --- |
| `MOCK_ECHO_UUID_ECHO_MOCK` | Generates a UUID | `{ "uuid" : "MOCK_ECHO_UUID_ECHO_MOCK" }` <br> Returns: `{ "uuid" : "d2694e87-1ae2-469b-8bd2-0394579ee366" }` |
| `MOCK_ECHO_RANDOM_STRING_<length>_ECHO_MOCK` | Generates random string of specified length | `{ "name" : "MOCK_ECHO_RANDOM_STRING_10_ECHO_MOCK MOCK_ECHO_RANDOM_STRING_5_ECHO_MOCK" }` <br> Returns: `{ "name" : "yzfCewAVAJ ZpptW" }` |
| `MOCK_ECHO_RANDOM_NUMBER_<length>_ECHO_MOCK` | Generates random number of specified length | `{ "phone" : "MOCK_ECHO_RANDOM_NUMBER_10_ECHO_MOCK" }` <br> Returns: `{ "phone" : "4008756974" }` |
| `MOCK_ECHO_CURRENT_DATETIME_<date-time-format>_ECHO_MOCK` | Sets the current date time in mentioned format | `{ "current_date_time" : "MOCK_ECHO_CURRENT_DATETIME_YYYY/MM/DD MMM ddd HH:mm:ss UTC_ECHO_MOCK"}` <br> Returns: `{ "current_date_time" : "2017/08/16 Aug Wed 18:32:34 UTC"}` |

Sample:
```sh
deepak.rai@localhost tmp $  curl -d '{"person_info": {"id": "MOCK_ECHO_UUID_ECHO_MOCK","name": "MOCK_ECHO_RANDOM_STRING_10_ECHO_MOCK MOCK_ECHO_RANDOM_STRING_5_ECHO_MOCK","phone" : "MOCK_ECHO_RANDOM_NUMBER_10_ECHO_MOCK","current_date_time" : "MOCK_ECHO_CURRENT_DATETIME_YYYY/MM/DD MMM ddd HH:mm:ss UTC_ECHO_MOCK "}}' "http://localhost:8014/setViaPost?url=macroTest"
OK
deepak.rai@localhost tmp curl http://localhost:8014/macroTest | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   170    0   170    0     0   2244      0 --:--:-- --:--:-- --:--:--  2266
{
    "person_info": {
        "current_date_time": "2017/08/16 Aug Wed 18:32:34 UTC ",
        "id": "d2694e87-1ae2-469b-8bd2-0394579ee366",
        "name": "yzfCewAVAJ ZpptW",
        "phone": "4008756974"
    }
}
deepak.rai@localhost tmp $ curl http://localhost:8014/macroTest | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   170    0   170    0     0   5202      0 --:--:-- --:--:-- --:--:--  5312
{
    "person_info": {
        "current_date_time": "2017/08/17 Aug Thu 13:38:45 UTC ",
        "id": "993922f6-794f-4f22-81b2-10f47d1d8e17",
        "name": "xhvZiQFbZY USyRO",
        "phone": "8035831104"
    }
}
deepak.rai@localhost tmp $ curl http://localhost:8014/macroTest | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   170    0   170    0     0   5480      0 --:--:-- --:--:-- --:--:--  5666
{
    "person_info": {
        "current_date_time": "2017/08/17 Aug Thu 13:38:54 UTC ",
        "id": "79804f3a-0aab-4c18-97c8-3a5770001822",
        "name": "KTuCPHTpBK MrXbd",
        "phone": "2476616451"
    }
}
```




Required to pass the optional port(`SERVER_PORT`) in the docker run command, on which the HTTP server is intended to run.
- For initial bootstrapping of URL's, can mount a csv file which consists of `"url","response",responseCode` to `/var/lib/mock-echo/sample.csv`, which will be loaded onto mock-echo.
- Server logs can be found in `/var/logs/mock-echo/server.log` inside the docker.

Docker run command : `docker run -t -d --net=host -e SERVER_PORT=<http-server-port> <optional-sample-csv-file-mount> <docker-image>`

Sample Docker run command : `docker run --name mock-echo -t -d --net=host -e SERVER_PORT=8014 -v /home/deepak.rai/mock/sample.csv:/var/lib/mock-echo/sample.csv drai82/mock-echo`

## Endpoints ##

- `/set` : Set the desired request URL, response, response code in URL parameters to mock-echo. URL parameters:
  - `url` : Url request path
  - `response` : Response to be returned
  - `responseCode` : Response code to be returned. By default, set to 200.
  - additional url parameters : Url parameters in addition to the URL. For example, `a=b&c=d`
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/set?url=hello&response=\[\{"target":"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count"\}\]&responseCode=404&a=b&c=d'
    {
        "url": "hello",
        "parameters": "a=b&c=d",
        "response": "[{\"target\":\"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count\"}]",
        "responseCode": "404",
        "counter": 0
    }
    ```
- `/setViaPost` : Same as `/set`, but send HTTP response via POST request. URL parameters:
  - `url` : Url request path
  - `responseCode` : Response code to be returned. By default, set to 200.
  - additional url parameters : Url parameters in addition to the URL. For example, `a=b&c=d`
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ $ curl -d '{"name": "mkyong","age": 30,"address": {"streetAddress": "88 8nd Street","city": "New York"},"phoneNumber": [{"type": "home","nber": "111 111-1111"},{"type": "fax","number": "222 222-2222"}]}' "http://localhost:8014/setViaPost?url=hello10&myParam1=a&myParam2=b"
    OK
    ```
- `/setBulkViaCSV` : Upload a csv consisting of `"url","parameters","response","responseCode"` entries and use it for bulk setting up of URL's.
  - Sample:
  ```sh
  deepak.rai@localhost tmp $ cat sample.csv
  "hello1","","response1",200
  "hello3"
  "hello2","","response2","404"
  "hello4","a=b","[""]"
  "hello5","c=b","buss"
  "hello6","x=5&y=9","[{""target"":""prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.1count""}]"
  "hello7","mykey1=5&my_key2=93","imksddsdazwsexdcrftvgbyhunjimkjnhgtfdrxeswsedrcftvgybh"

  deepak.rai@localhost tmp $ curl -F 'data=@sample.csv' "http://localhost:8014/setBulkViaCSV"
  OK
  ```
- `/get` : Get the details of request URL. Returns - request URL path, response, response code and hit count. URL parameters:
  - `url` : Url request path
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/get?url=hello&a=b&c=d'
    {
        "url": "hello",
        "parameters": "a=b&c=d",
        "response": "[{\"target\":\"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count\"}]",
        "responseCode": 404,
        "counter": 3
    }
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/get?url=nonExistentRequestPath'
    {
        "error": "URL not set"
    }
    ```
- `/reset` : Reset the counter of request URL. URL parameters:
  - `url` : Url request path
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl 'http://localhost:8014/reset?url=hello'
    {
        "url": "hello",
        parameters: "",
        "response": "[{\"target\":\"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count\"}]",
        "responseCode": 404,
        "counter": 0
    }
    ```
- Hit the already set request path URL, should return the intended response. mock-echo internally will the bump the counter for this request path. Sample, set to a specific response and the response code to 404:
```sh
deepak.rai@localhost tmp $ curl 'http://localhost:8014/hello' -i
HTTP/1.1 404 Not Found
Date: Wed, 19 Jul 2017 02:31:58 GMT
Connection: keep-alive
Transfer-Encoding: chunked

[{"target":"prod.uh1.geo-1.app.geo-svc-1001_app_uh1_geo_prod.guardian.bssidFileSize.count"}]
```
- `/delete` : Delete the set request URL, response, response code for given URL parameters in mock-echo. URL parameters:
  - `url` : Url request path
  - `responseCode` : Response code to be returned. By default, set to 200.
  - additional url parameters : Url parameters in addition to the URL. For example, `a=b&c=d`
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl "http://localhost:8014/delete?url=hello&a=b&c=d"
    Deleted successfully!
    ```
- `/fileUpload` : File hosting. URL parameters:
  - `url` : Url request path
   - Sample:
   ```sh
   deepak.rai@localhost tmp $ curl -X POST -F 'file=@myFile.png' "http://localhost:8014/fileUpload"
   File uploaded!
   deepak.rai@localhost tmp $ curl -X POST -F 'file=@temp.txt' http://localhost:8014/fileUpload?url=hello/world/
   File uploaded!
   deepak.rai@localhost tmp $ curl -X POST -F 'file=@myImage.png' "http://localhost:8014/fileUpload?url=hello/world/&myParam1=a1&myParam2=b2"
   File uploaded !
   ```
- `/fileDownload` : Download a hosted file.
  - Sample:
  ```sh
  deepak.rai@localhost tmp $  wget "http://localhost:8014/fileDownload/hello/world/myFile.png"
  --2017-09-18 14:31:29--  http://localhost:8014/fileDownload/hello/world/myFile.png
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 204804 (200K) [image/png]
  Saving to: 'myFile.png.1'

  myFile.png.1                  100%[================================================>] 200.00K  --.-KB/s   in 0.001s

  2017-09-18 14:31:29 (197 MB/s) - 'myFile.png.1' saved [204804/204804]

  deepak.rai@localhost tmp $  wget "http://localhost:8014/hello/world/myFile.png"
  --2017-09-18 14:31:39--  http://localhost:8014/hello/world/myFile.png
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: unspecified [application/octet-stream]
  Saving to: 'myFile.png.2'

  myFile.png.2                      [ <=>                                             ] 200.00K  --.-KB/s   in 0s

  2017-09-18 14:31:39 (519 MB/s) - 'myFile.png.2' saved [204804]

  deepak.rai@localhost tmp wget "http://localhost:8014/hello/world/myImage.png?myParam1=a1&myParam2=b2"
  --2017-09-18 14:36:30--  http://localhost:8014/hello/world/myImage.png?myParam1=a1&myParam2=b2
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: unspecified [application/octet-stream]
  Saving to: 'myImage.png?myParam1=a1&myParam2=b2'

  myImage.png?myParam1=a1&myPar     [ <=>                                             ] 200.00K  --.-KB/s   in 0s

  2017-09-18 14:36:30 (462 MB/s) - 'myImage.png?myParam1=a1&myParam2=b2' saved [204804]

  deepak.rai@localhost tmp $ wget "http://localhost:8014/fileDownload/hello/world/temp.txt"
  --2017-09-05 15:31:29--  http://localhost:8014/fileDownload/hello/world/temp.txt
  Resolving localhost... ::1, 127.0.0.1
  Connecting to localhost|::1|:8014... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 20 [text/plain]
  Saving to: 'temp.txt.1'

  temp.txt.1                                                 100%[==========================================================================================================================================>]      20  --.-KB/s   in 0s

  2017-09-05 15:31:29 (2.12 MB/s) - 'temp.txt.1' saved [20/20]
  ```
- `/fileDelete` : Download a hosted file.  URL parameters:
  - `file` : Filename to be deleted
    - Sample:
    ```sh
    deepak.rai@localhost tmp $ curl "http://localhost:8014/fileDelete?file=myFile.png"
    File deleted successfully - myFile.png !
    deepak.rai@localhost tmp $ curl "http://localhost:/fileDelete?file=hello/world/temp.txt"
    File deleted successfully - hello/world/temp.txt !
    ```

## Macros ##

mock-echo supports some pre-defined placehoder macros in response which gets replaced at runtime:

| Macro | Description | Sample |
| --- | --- | --- |
| `MOCK_ECHO_UUID_ECHO_MOCK` | Generates a UUID | `{ "uuid" : "MOCK_ECHO_UUID_ECHO_MOCK" }` <br> Returns: `{ "uuid" : "d2694e87-1ae2-469b-8bd2-0394579ee366" }` |
| `MOCK_ECHO_RANDOM_STRING_<length>_ECHO_MOCK` | Generates random string of specified length | `{ "name" : "MOCK_ECHO_RANDOM_STRING_10_ECHO_MOCK MOCK_ECHO_RANDOM_STRING_5_ECHO_MOCK" }` <br> Returns: `{ "name" : "yzfCewAVAJ ZpptW" }` |
| `MOCK_ECHO_RANDOM_NUMBER_<length>_ECHO_MOCK` | Generates random number of specified length | `{ "phone" : "MOCK_ECHO_RANDOM_NUMBER_10_ECHO_MOCK" }` <br> Returns: `{ "phone" : "4008756974" }` |
| `MOCK_ECHO_CURRENT_DATETIME_<date-time-format>_ECHO_MOCK` | Sets the current date time in mentioned format | `{ "current_date_time" : "MOCK_ECHO_CURRENT_DATETIME_YYYY/MM/DD MMM ddd HH:mm:ss UTC_ECHO_MOCK"}` <br> Returns: `{ "current_date_time" : "2017/08/16 Aug Wed 18:32:34 UTC"}` |

Sample:
```sh
deepak.rai@localhost tmp $  curl -d '{"person_info": {"id": "MOCK_ECHO_UUID_ECHO_MOCK","name": "MOCK_ECHO_RANDOM_STRING_10_ECHO_MOCK MOCK_ECHO_RANDOM_STRING_5_ECHO_MOCK","phone" : "MOCK_ECHO_RANDOM_NUMBER_10_ECHO_MOCK","current_date_time" : "MOCK_ECHO_CURRENT_DATETIME_YYYY/MM/DD MMM ddd HH:mm:ss UTC_ECHO_MOCK "}}' "http://localhost:8014/setViaPost?url=macroTest"
OK
deepak.rai@localhost tmp curl http://localhost:8014/macroTest | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   170    0   170    0     0   2244      0 --:--:-- --:--:-- --:--:--  2266
{
    "person_info": {
        "current_date_time": "2017/08/16 Aug Wed 18:32:34 UTC ",
        "id": "d2694e87-1ae2-469b-8bd2-0394579ee366",
        "name": "yzfCewAVAJ ZpptW",
        "phone": "4008756974"
    }
}
deepak.rai@localhost tmp $ curl http://localhost:8014/macroTest | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   170    0   170    0     0   5202      0 --:--:-- --:--:-- --:--:--  5312
{
    "person_info": {
        "current_date_time": "2017/08/17 Aug Thu 13:38:45 UTC ",
        "id": "993922f6-794f-4f22-81b2-10f47d1d8e17",
        "name": "xhvZiQFbZY USyRO",
        "phone": "8035831104"
    }
}
deepak.rai@localhost tmp $ curl http://localhost:8014/macroTest | python -m json.tool
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   170    0   170    0     0   5480      0 --:--:-- --:--:-- --:--:--  5666
{
    "person_info": {
        "current_date_time": "2017/08/17 Aug Thu 13:38:54 UTC ",
        "id": "79804f3a-0aab-4c18-97c8-3a5770001822",
        "name": "KTuCPHTpBK MrXbd",
        "phone": "2476616451"
    }
}
```

