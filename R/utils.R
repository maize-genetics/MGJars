# === Utilities =====================================================

## ----
#' @title Get directory fields for installed package
#' 
#' @param pkg Package name
#' @param sep Directory separator character
getDirFields <- function(pkg = "MGJars", sep = "/") {
    pkgDir   <- find.package(pkg)
    javaDir  <- "java/"
    metaDir  <- "extdata/"
    metaFile <- "bljars_metadata.csv"

    return(
        list(
            pkgDir   = pkgDir,
            javaDir  = javaDir,
            metaDir  = metaDir,
            fullJava = paste0(pkgDir, sep, javaDir),
            fullMeta = paste0(pkgDir, sep, metaDir),
            metaPath = paste0(pkgDir, sep, metaDir, metaFile)
        )
    )
}


## ----
#' @title Create Enum collections
#' 
#' @param ... Lists of elements to add to \code{Enum} instance
Enum <- function(...) {
    
    values <- sapply(match.call(expand.dots = TRUE)[-1L], deparse)
    
    stopifnot(identical(unique(values), values))
    
    res <- setNames(seq_along(values), values)
    res <- as.environment(as.list(res))
    lockEnvironment(res, bindings = TRUE)
    res
}


