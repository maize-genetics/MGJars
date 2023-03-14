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
#' @title Create Enum collections and lock bindings
#' 
#' @param l List of elements to add to \code{Enum} instance
Enum <- function(l) {
    stopifnot(is.list(l))
    
    res <- as.environment(l)
    
    lockEnvironment(res, bindings = TRUE)
    
    return(res)
}


