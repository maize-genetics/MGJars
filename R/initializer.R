## ----
#' @title Get TASSEL standalone JAR metadata
#'
#' @description Get commit history and download links
#'
#' @param apiPath Path to TASSEL Bitbucket API.
#' @param pageLen Number of pages to return. Defaults to \code{100}.
#'
#' @return A data.frame
getCommitMetaData <- function(
    apiPath = "https://api.bitbucket.org/2.0/repositories/tasseladmin/tassel-5-standalone/src/master/",
    pageLen = 100
) {
    urlLib <- paste0(apiPath, "/lib?pagelen=", pageLen)

    cli::cli_progress_step("Downloading JSON info", spinner = TRUE)
    jsonTop <- jsonlite::fromJSON(apiPath)
    jsonLib <- jsonlite::fromJSON(urlLib)

    jsonTop$values$attributes[sapply(jsonTop$values$attributes, is.null)] <- NA
    jsonLib$values$attributes[sapply(jsonLib$values$attributes, is.null)] <- NA


    cli::cli_progress_step("Collecting metdata", spinner = TRUE)
    urlLibDF <- data.frame(
        jar        = jsonLib$values$path,
        attribute  = unlist(jsonLib$values$attributes),
        commitMeta = jsonLib$values$commit$links$self$href,
        downLink   = jsonLib$values$links$self$href
    )
    urlTopDF <- data.frame(
        jar        = jsonTop$values$path,
        attribute  = unlist(jsonTop$values$attributes),
        commitMeta = jsonTop$values$commit$links$self$href,
        downLink   = jsonTop$values$links$self$href
    )

    cli::cli_progress_step("Cleaning up data", spinner = TRUE)
    urlLibDF <- urlLibDF[!grepl(".ini$|.dylib$", urlLibDF$jar), ]
    urlTopDF <- urlTopDF[urlTopDF$jar == "sTASSEL.jar", ]
    urlMasterDf <- rbind(urlTopDF, urlLibDF)
    urlMasterDf$commitDate <- as.Date("")

    cli::cli_progress_step("Collecting commit history", spinner = TRUE)
    j <- 1
    for (i in urlMasterDf$commitMeta) {
        tmpJson <- jsonlite::fromJSON(i)
        urlMasterDf$commitDate[j] <- as.Date(tmpJson$date)
        j <- j + 1
    }

    rownames(urlMasterDf) <- NULL
    urlMasterDf$jar <- gsub("lib/", "", urlMasterDf$jar)

    return(urlMasterDf)
}



## ----
#' @title Initialize \code{BLJars}.
#'
#' @description Download jar files to designated directory
#'
#' @return void
#' @export
initializeJars <- function() {

    fields <- getDirFields()

    if (!dir.exists(fields$fullJava)) {
        dir.create(fields$fullJava, recursive = TRUE)
    }

    md <- getCommitMetaData()

    if (!dir.exists(fields$fullMeta)) {
        dir.create(fields$fullMeta, recursive = TRUE)
    }

    write.csv(
        x = md,
        file = fields$metaPath,
        row.names = FALSE,
        quote = FALSE
    )

    j <- 1
    cli::cli_progress_bar("Downloading jar files", total = nrow(md))
    for (i in md$downLink) {
        dest <- paste0(fields$fullJava, md$jar[j])
        utils::download.file(i, dest, quiet = TRUE)
        cli::cli_progress_update()
        j <- j + 1
    }
    cli::cli_alert_success("Downloaded {nrow(md)}/{nrow(md)} jar files.")
}



