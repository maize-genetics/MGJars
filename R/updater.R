## ----
#' @title Update jar files.
#'
#' @description Updates jar files to designated directory
#'
#' @param test Debug.
#'
#' @return void
#' @export
updateJars <- function(test = TRUE) {

    paths <- getDirFields()
    blVersions <- rJava::.jnew("net/maizegenetics/tassel/TasselVersions")

    if (test) {
        metaDf <- read.csv("/home/btmonier/Temporary/test_rtassel/mgjars_metadata_old.csv")
    } else {
        metaDf <- read.csv(metaPath)
    }


    # Get current
    currentArtifacts <- gsub("-[^-]+$|\\.jar", "", metaDf$jar)
    currentVersionId <- gsub("\\.jar|^.*-", "", metaDf$jar)

    currentTasselVersion <- blVersions$tasselVersion()
    currentPhgVersion <- blVersions$phgVersion()

    currentVersionId <- replace(currentVersionId, currentVersionId == "sTASSEL", currentTasselVersion)
    currentVersionId <- replace(currentVersionId, currentVersionId == "phg", currentPhgVersion)

    currentMeta <- data.frame(
        artifact = currentArtifacts,
        current_version_id = currentVersionId
    )


    # Get latest
    getLatestMavenVersion <- function(artifact) {
        mavenUrl <- sprintf("https://search.maven.org/solrsearch/select?q=a:%s", artifact)
        jsonResp <- jsonlite::fromJSON(mavenUrl)
        return(jsonResp$response$docs$latestVersion)
    }


    getLatestJars <- function(
        apiPath = "https://api.bitbucket.org/2.0/repositories/tasseladmin/tassel-5-standalone/src/master/",
        pageLen = 100
    ) {
        urlLib <- paste0(apiPath, "/lib?pagelen=", pageLen)
        jsonTop <- jsonlite::fromJSON(apiPath)
        jsonLib <- jsonlite::fromJSON(urlLib)

        # jsonTop$values$attributes[sapply(jsonTop$values$attributes, is.null)] <- NA
        # jsonLib$values$attributes[sapply(jsonLib$values$attributes, is.null)] <- NA

        urlLibDF <- data.frame(
            jar        = jsonLib$values$path,
            # attribute  = unlist(jsonLib$values$attributes),
            commitMeta = jsonLib$values$commit$links$self$href,
            downLink   = jsonLib$values$links$self$href
        )
        urlTopDF <- data.frame(
            jar        = jsonTop$values$path,
            # attribute  = unlist(jsonTop$values$attributes),
            commitMeta = jsonTop$values$commit$links$self$href,
            downLink   = jsonTop$values$links$self$href
        )

        urlLibDF <- urlLibDF[!grepl(".ini$|.dylib$", urlLibDF$jar), ]
        urlTopDF <- urlTopDF[urlTopDF$jar == "sTASSEL.jar", ]
        urlMasterDf <- rbind(urlTopDF, urlLibDF)

        rownames(urlMasterDf) <- NULL
        urlMasterDf$jar <- gsub("lib/", "", urlMasterDf$jar)

        return(urlMasterDf)
    }


    latestMeta <- getLatestJars()

    latestArtifacts <- gsub("-[^-]+$|\\.jar", "", latestMeta$jar)
    latestVersionId <- gsub("\\.jar|^.*-", "", latestMeta$jar)

    latestTasselVersion <- getLatestMavenVersion("tassel")
    latestPhgVersion <- getLatestMavenVersion("phg")
    latestVersionId <- replace(latestVersionId, latestVersionId == "sTASSEL", latestTasselVersion)
    latestVersionId <- replace(latestVersionId, latestVersionId == "phg", latestPhgVersion)


    latestMeta <- data.frame(
        artifact = latestArtifacts,
        latest_version_id = latestVersionId,
        download_path = latestMeta$downLink
    )

    # Evaluate current vs latest
    evalDf <- merge(latestMeta, currentMeta, by = "artifact", all = TRUE)

    diffs   <- evalDf[which(evalDf$latest_version_id != evalDf$current_version_id), ]
    adds    <- evalDf[which(is.na(evalDf$current_version_id)), ]
    removes <- evalDf[which(is.na(evalDf$latest_version_id)), ]

    diffs$artifact

    printArifact        <- sprintf("%-*s", max(nchar(diffs$artifact)) + 1, diffs$artifact)
    printCurrentVersion <- sprintf("%-*s", max(nchar(diffs$current_version_id)) + 1, diffs$current_version_id)
    printLatestVersion  <- sprintf("%-*s", max(nchar(diffs$latest_version_id)), diffs$latest_version_id)

    diffMessage <- paste0("  * ", printArifact, "(", printCurrentVersion, "-> ", printLatestVersion, ")", sep = "\n")

    message("The following jar(s) are out of date:")
    message(diffMessage)



    if (length(adds) > 0) {
        addsPrintArifact        <- sprintf("%-*s", max(nchar(adds$artifact)) + 1, adds$artifact)
        addsPrintCurrentVersion <- sprintf("%-*s", max(nchar(adds$latest_version_id)), adds$latest_version_id)

        addsDiffMessage <- paste0("  * ", addsPrintArifact, "(", addsPrintCurrentVersion, ")", sep = "\n")

        message("The following jar(s) will be added:")
        message(addsDiffMessage)
    }

    answer <- -1
    while (!(answer == "y" || answer == "n" || answer == "")) {
        answer <- readline(prompt = "Proceed ([y]/n): ")
        answer <- tolower(answer)
        if (!(answer == "y" || answer == "n" || answer == "")) {
            message("Invalid answer. Try again.")
        }
    }

    if (answer == "y" || answer == "") {
        message("Updating artifacts...")
    } else {
        message("Exiting.")
    }
}


