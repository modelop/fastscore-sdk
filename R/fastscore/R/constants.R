# Disable all SSL certificate checking
httr::set_config(config(ssl_verifypeer=0L))
httr::set_config(config(use_ssl=0L))
httr::set_config(config(ssl_verifyhost=0L))

MODEL_CONTENT_TYPES <- list(
    'pfa-json'      ='application/vnd.fastscore.model-pfa+json',
    'pfa-yaml'      ='application/vnd.fastscore.model-pfa-yaml',
    'pfa-pretty'    ='application/vnd.fastscore.model-pfa-pretty',
    'h2o-java'      ='application/vnd.fastscore.model-h2o-java',
    'python'        ='application/vnd.fastscore.model-python',
    'python3'       ='application/vnd.fastscore.model-python3',
    'R'             ='application/vnd.fastscore.model-r',
    'java'          ='application/vnd.fastscore.model-java',
    'jupyter'       ='application/vnd.fastscore.model-jupyter',
    'c'             ='application/vnd.fastscore.model-c'
    )

ATTACHMENT_CONTENT_TYPES <- list(
    'zip'='application/zip',
    'tgz'='application/gzip'
    )
