# fastscore.schema.0: cpi
# fastscore.schema.2: close
# fastscore.schema.1: double
# fastscore.schema.3: adjustment
# fastscore.schema.5: double

begin <- function(){
    slope <<- 0.0002319547958991928
    intercept <<- 0.4380634632578033

    cpis <<- list()
    sp500s <<- list()
}

action <- function(data, slot){
    if(slot == 2){ # SP500 input
        count <- length(sp500s)
        sp500s[[count + 1]] <<- data
        emitTo(5, data[['Close']])
    }
    if(slot == 0){ # CPI input
        count <- length(cpis)
        cpis[[count + 1]] <<- data
    }

    while(length(sp500s) > 0 && length(cpis) > 0){
        sp500 <- sp500s[[1]]
        sp500s[[1]] <<- NULL # pop from the front of the list
        cpi <- cpis[[1]]
        cpis[[1]] <<- NULL

        date <- sp500[['Date']] # Assume inputs in both streams are ordered
        lin_reg = reg(date)
        adjusted_price <- rescale(sp500[['Close']], cpi[['CPI']]) - lin_reg

        lin_reg_plus_one = reg(date + 1) # what to remove from the output
        adjustment <- list("LR"=lin_reg_plus_one, "CPI"=cpi[['CPI']])

        emitTo(1, adjusted_price)
        emitTo(3, adjustment)
    }
}

rescale <- function(close, cpi){
    close/cpi
}

reg <- function(date){
    slope*date + intercept
}
