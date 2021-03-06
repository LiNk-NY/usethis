proj <- new.env(parent = emptyenv())

proj_crit <- function() {
  rprojroot::has_file(".here") |
    rprojroot::is_rstudio_project |
    rprojroot::is_r_package |
    rprojroot::is_git_root |
    rprojroot::is_remake_project |
    rprojroot::is_projectile_project
}

proj_find <- function(path = ".") {
  tryCatch(
    rprojroot::find_root(proj_crit(), path = path),
    error = function(e) NULL
  )
}

is_proj <- function(path = ".") !is.null(proj_find(path))

is_package <- function(base_path = proj_get()) {
  res <- tryCatch(
    rprojroot::find_package_root_file(path = base_path),
    error = function(e) NULL
  )
  !is.null(res)
}

check_is_package <- function(whos_asking = NULL) {
  if (is_package()) {
    return(invisible())
  }

  message <- paste0(
    "Project ", value(project_name()), " is not an R package."
  )
  if (!is.null(whos_asking)) {
    message <- paste0(
      code(whos_asking),
      " is designed to work with packages. ",
      message
    )
  }
  stop(message, call. = FALSE)
}

#' Get and set the active project
#'
#' When attached, usethis uses [rprojroot](https://krlmlr.github.io/rprojroot/)
#' to find the project root of the current working directory. It establishes the
#' project root by looking for a `.here` file, an RStudio project, a package
#' `DESCRIPTION`, Git infrastructure, a `remake.yml` file, or a `.projectile`
#' file. It then stores the project directory for use for the remainder of the
#' session. If needed, you can manually override by running `proj_set()`.
#'
#' @param path Path to set.
#' @param force If `TRUE`, use this path without checking the usual criteria.
#'   Use sparingly! The main application is to solve a temporary chicken-egg
#'   problem: you need to set the active project in order to add
#'   project-signalling infrastructure, such as initialising a Git repo or
#'   adding a DESCRIPTION file.
#' @keywords internal
#' @export
proj_get <- function() {
  if (!is.null(proj$cur)) {
    return(proj$cur)
  }

  # Try current wd
  proj_set(".")
  if (!is.null(proj$cur)) {
    return(proj$cur)
  }

  stop(
    "Current working directory, ", value(normalizePath(".")), ", ",
    " does not appear to be inside a project or package.",
    call. = FALSE
  )
}

#' @export
#' @rdname proj_get
proj_set <- function(path = ".", force = FALSE) {
  old <- proj$cur

  if (force) {
    proj$cur <- path
  } else {
    proj$cur <- proj_find(path)
  }

  invisible(old)
}

proj_path <- function(...) file.path(proj_get(), ...)
