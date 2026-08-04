# file-management.R


#' move_targets_to_gdrive
#' This function creates a targets store in the specified directory on Google Drive
#' (if it doesn't exist yet) and moves all target objects from `store` to gdrive.
#' Targets you wish to keep locally must be indicated in a character vector 
#' `obj2keep`.
#' 
#' @param store _targets store directory
#' @param obj2keep list of targets to keep locally
#' @param gdrive_dir directory on Google Drive to copy the data to
move_targets_to_gdrive <- function(store, obj2keep, gdrive_dir) {
  if ( !fs::dir_exists(paste0(gdrive_dir, "/", store)) ) {
    fs::dir_create(paste0(gdrive_dir, "/", store))
  }
  objs      <- tar_objects(store = store)  # list of all objects
  objs2move <- objs[!(objs %in% obj2keep)] # objects to be moved
  if (length(objs2move) >= 1) {
    fs::file_move(
      paste0(store, "/objects/", objs2move),
      paste0(gdrive_dir, "/", store)
    )
  }
}



