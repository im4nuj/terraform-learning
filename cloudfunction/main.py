import google.cloud.dlp
import base64
import json

HTTP_SUCCESS = 200

def decrypt(request):
    payload=request.get_json()
    action = "crypto_replace_ffx_fpe"
    config = action + "_config"
    dlp = google.cloud.dlp_v2.DlpServiceClient()
    print(dlp)
    parent = f"projects/dmp-test2"
    wrapped_key = base64.b64decode(
        'CiQAuW+6m3y5TRstqrWskxbXwYMIeT5Z3XIqSGklSyvGSs3z/TwSSQC7jqoQwTstARXDjwfTrvxJVCAJXwMwp6hmqzwoIORYthtC0jSHCUcFj7lUEqDs0pq46bz4Lq1WYyZEgOgH7IL6gI6o8r9yME0=')
    crypto_replace_ffx_fpe_config = {
        "crypto_key": {
            "kms_wrapped": {"wrapped_key": wrapped_key,
                            "crypto_key_name": "projects/dmp-test2/locations/global/keyRings/dlp-keyring/cryptoKeys/dlp-key-poc"}
        },
        "common_alphabet": 4,
        "radix": 95
    }

    crypto_replace_ffx_fpe_config["surrogate_info_type"] = {"name": "PII_DATA"}

    reidentify_config = {
        "record_transformations": {
            "field_transformations": [
                {   "fields":getheaderName(payload["data"][0]),
                    "primitive_transformation": {
                        config: locals()[config]
                    }
                }
            ]
        }
    }

    item = snowToDlpRow(payload)
    print(item)
    request = {"parent": parent,
                   "reidentify_config": reidentify_config,
                   "item": item}
    response = dlp.reidentify_content(
            request)
    print(response.item.table)
    return_value=responseConverter(response.item.table)
    json_response = json.dumps( { "data" : return_value } )
    return (json_response,HTTP_SUCCESS)

def snowToDlpRow(request):

    headers=[]
    rows=[]
    headers=getheaderName(request["data"][0])
    for row in request["data"]:
        index = 1
        value = []
        while index < len(row):
            value.append({"string_value": row[index]})
            index += 1
        rows.append({"values":value})
    #print(rows)
    item = {"table": {
        "headers": headers,
        "rows": rows
    }}
    return item

def getheaderName(_data):
    headers=[]
    temp=1
    while temp < len(_data):
        headers.append({"name": "Col"+str(temp)})
        temp += 1
    return headers

def responseConverter(_response):
    finalResponse=[]
    temp = 0
    for row in _response.rows:
        resp=[]
        resp.append(temp)
        for value in row.values:
            resp.append(value.string_value)
        #val=[temp,resp]
        finalResponse.append(resp)
        temp = temp+1
    return finalResponse

