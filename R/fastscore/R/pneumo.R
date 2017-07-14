
PneumoSock <- setRefClass("PneumoSock",
    fields=list(
        proxy_prefix = "character"
    ),
    methods=list(
        recv = function(){
            stop("Not implemented!") # TODO
        },
        close = function(){
            stop("Not implemented!") # TODO
        }
    )
)

pneumo.make_message <- function(data){
    src <- data[['src']]
    timestamp <- data[['timestamp']]
    ptype <- data[['type']]
    if(ptype == 'health'){
        return(HealthMsg$new(src=src,
            timestamp=timestamp,
            instance=data[['instance']],
            health=data[['health']]))
    }
    else if(ptype == 'log'){
        return(LogMsg$new(src=src,
            timestamp=timestamp,
            level=data[['level']],
            text=data[['text']]))
    }
    else if(ptype == 'model-console'){
        return(ModelConsoleMsg$new(src=src,
            timestamp=timestamp,
            text=data[['text']]))
    }
    else if(ptype == 'output-eof'){
        return(OutputEOFMsg$new(src=src,
            timestamp=timestamp,
            last=data[['last']]))
    }
    else if(ptype == 'sensor-report'){
        return(SensorReportMsg$new(src=src,
            timestamp=timestamp,
            tapid=data[['id']],
            point=data[['tap']],
            data=data[['data']]))
    }
    else if(ptype == 'jet-status-report'){
        return(JetStatusReportMsg$new(src=src,
            timestamp=timestamp,
            jets=data[['jets']]))
    }
    else{
        stop(paste("FastScoreError: Unexpected Pneumo message type:", ptype))
    }
}

PneumoMsg <- setRefClass("PneumoMsg",
    fields=list(
        src="character",
        timestamp="character"
    )
)

HealthMsg <- setRefClass("HealthMsg",
    contains="PneumoMsg",
    fields=list(
        instance="character", #TODO: Change this
        health="character"
    )
)

LogMsg <- setRefClass("LogMsg",
    contains="PneumoMsg",
    fields=list(
        level="numeric",
        text="character"
    )
)

ModelConsoleMsg <- setRefClass("ModelConsoleMsg",
    contains="PneumoMsg",
    fields=list(
        text="character"
    )
)

OutputEOFMsg <- setRefClass("OutputEOFMsg",
    contains="PneumoMsg",
    fields=list(
        last="character" # TODO: revisit
    )
)

SensorReportMsg <- setRefClass("SensorReportMsg",
    contains="PneumoMsg",
    fields=list(
        tapid="numeric",
        point="character",
        data="character" #TODO: revisit
    )
)

JetStatusReportMsg <- setRefClass("JetStatusReportMsg",
    contains="PneumoMsg",
    fields=list(
        jets="list"
    )
)
