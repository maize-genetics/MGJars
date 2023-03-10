.onLoad <- function(libname, pkgname) {
    ## naive check for JAR detection
    fields <- getDirFields()
    if (any(grepl("jar", list.files(fields$fullJava)))) {
        rJava::.jpackage(pkgname, lib.loc = libname)
        rJava::.jaddClassPath(dir(file.path(getwd(), "inst/java"), full.names = TRUE))
    }
}


.onAttach <- function(libname, pkgname) {
    fields <- getDirFields()
    if (!any(grepl("jar", list.files(fields$fullJava)))) {
        msg <- paste0(
            "This looks like your first time running MGJars:", "\n",
            "  * Please run 'initializeJars()'", "\n",
            "    - This will download JAR files to the package.", "\n",
            "  * Once finished, please reload the MGJars package."
        )
    } else {
        tasselVersions <- rJava::.jnew("net/maizegenetics/tassel/TasselVersions")

        msg <- paste0(
            "MGJars package successfully loaded:", "\n",
            "  * MGJars version....... ", utils::packageVersion("MGJars"), "\n",
            "  * PHG version.......... ", tasselVersions$phgVersion(), "\n",
            "  * TASSEL version....... ", tasselVersions$tasselVersion(), "\n",
            "  * Build date........... ", tasselVersions$tasselVersionDate(), "\n"
        )

    }

    packageStartupMessage(msg)
}


